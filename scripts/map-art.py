"""地図の土台のドット絵を描く。

海・浅瀬・陸・山・富士山・琵琶湖・浜名湖を、228x150 px の PNG に描く。
道・名所の印・相棒は進み具合で変わるので、アプリが上に重ねる。
経度と緯度から点への写し方は JourneyMapGeometry.swift の project とそろえる。描き方の決まりは docs/decisions/landmark.md にある。
出力先が .xcassets なら imageset を作り、そうでなければ 3 倍に広げた見本も書く。

    python3 -I scripts/map-art.py <出力先>
"""
import json
import struct
import sys
import zlib
from pathlib import Path

W, H = 228, 150

LAND = [
    (135.3, 36.6), (140.5, 36.6), (140.5, 35.25), (140.1, 35.0), (139.85, 34.92),
    (139.75, 35.15), (139.95, 35.45), (139.8, 35.64), (139.68, 35.5), (139.65, 35.3),
    (139.7, 35.15), (139.55, 35.27), (139.3, 35.3), (139.15, 35.15), (139.1, 34.95),
    (138.95, 34.65), (138.85, 34.6), (138.75, 34.75), (138.85, 35.05), (138.6, 35.1),
    (138.5, 34.95), (138.25, 34.6), (137.7, 34.65), (137.3, 34.6), (137.0, 34.6),
    (137.25, 34.75), (137.05, 34.85), (136.95, 34.7), (136.85, 34.9), (136.85, 35.05),
    (136.62, 34.97), (136.52, 34.72), (136.72, 34.5), (136.85, 34.45), (136.8, 34.2),
    (135.3, 34.2),
]
BIWA = [
    (135.92, 35.0), (135.95, 35.2), (136.05, 35.42), (136.2, 35.52), (136.27, 35.42),
    (136.1, 35.2), (136.0, 35.02),
]
HAMANA = (137.6, 34.75)
FUJI = (138.73, 35.36)
MOUNTAINS = [
    (136.4, 35.9, 9), (137.4, 35.9, 11), (138.3, 35.8, 10), (139.2, 35.95, 8),
    (137.8, 35.4, 8), (136.2, 35.7, 7), (136.9, 36.15, 9), (138.0, 36.2, 12),
]
TREES = [
    (136.6, 35.45), (136.75, 35.5), (137.1, 35.35), (137.25, 35.5), (138.1, 35.55),
    (138.25, 35.45), (139.35, 35.6), (139.5, 35.75), (136.3, 35.3), (135.6, 35.6),
    (135.5, 35.3), (138.6, 35.75), (139.0, 35.7), (137.55, 35.05), (137.9, 34.95),
]

SEA = (150, 202, 214)
SEA_DEEP = (130, 186, 202)
SHALLOW = (184, 222, 226)
WAVE = (222, 240, 240)
SAND = (238, 222, 176)
LAND_C = (198, 216, 156)
LAND_DARK = (182, 202, 140)
COAST = (122, 140, 96)
LAKE = (140, 196, 214)
LAKE_EDGE = (96, 150, 170)


def project(lon, lat):
    return ((lon - 135.3) / 5.1 * W, (36.45 - lat) / 2.2 * H)


def noise(x, y, seed=0):
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def inside(poly, x, y):
    hit = False
    for (x0, y0), (x1, y1) in zip(poly, poly[1:] + poly[:1]):
        if (y0 > y) != (y1 > y) and x < (x1 - x0) * (y - y0) / (y1 - y0) + x0:
            hit = not hit
    return hit


class Canvas:
    def __init__(self):
        self.px = [[(0, 0, 0, 255)] * W for _ in range(H)]

    def put(self, x, y, c):
        if 0 <= x < W and 0 <= y < H:
            self.px[int(y)][int(x)] = (*c, 255)

    def get(self, x, y):
        return self.px[y][x][:3]


def masks():
    land_poly = [project(*p) for p in LAND]
    biwa_poly = [project(*p) for p in BIWA]
    hx, hy = project(*HAMANA)
    land = [[inside(land_poly, x + 0.5, y + 0.5) for x in range(W)] for y in range(H)]
    lake = [[False] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            in_biwa = inside(biwa_poly, x + 0.5, y + 0.5)
            in_hamana = ((x + 0.5 - hx + 1) / 3.6) ** 2 + ((y + 0.5 - hy + 1.5) / 2.4) ** 2 <= 1
            if land[y][x] and (in_biwa or in_hamana):
                lake[y][x] = True
    return land, lake


def near(mask, x, y, r):
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if abs(dx) + abs(dy) <= r and 0 <= x + dx < W and 0 <= y + dy < H and mask[y + dy][x + dx]:
                return True
    return False


def sea(cv, land):
    for y in range(H):
        for x in range(W):
            if land[y][x]:
                continue
            if near(land, x, y, 2):
                c = SHALLOW
            else:
                c = SEA_DEEP if y > H * 0.82 and noise(x, y, 2) > 0.35 else SEA
            cv.put(x, y, c)
    for y in range(4, H, 6):
        for x in range((y * 7) % 11, W, 13):
            if all(not near(land, x + k, y, 3) for k in range(3)):
                for k in range(3):
                    cv.put(x + k, y, WAVE)


def ground(cv, land, lake):
    for y in range(H):
        for x in range(W):
            if not land[y][x]:
                continue
            if lake[y][x]:
                edge = any(not lake[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                cv.put(x, y, LAKE_EDGE if edge else LAKE)
                continue
            sea_edge = any(
                not land[y + dy][x + dx]
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                if 0 <= x + dx < W and 0 <= y + dy < H
            )
            if sea_edge:
                cv.put(x, y, COAST)
            elif not near_sea(land, x, y):
                cv.put(x, y, LAND_DARK if noise(x // 3, y // 2, 5) > 0.9 else LAND_C)
            else:
                cv.put(x, y, SAND)


def near_sea(land, x, y):
    for dy in (-2, -1, 0, 1, 2):
        for dx in (-2, -1, 0, 1, 2):
            if abs(dx) + abs(dy) <= 2 and 0 <= x + dx < W and 0 <= y + dy < H and not land[y + dy][x + dx]:
                return True
    return False


def mountain(cv, cx, cy, half, body, light, snow=0):
    height = half + half // 2
    for row in range(height):
        y = cy - height + row + 1
        span = row * half // (height - 1)
        for x in range(cx - span, cx + span + 1):
            c = light if x < cx else body
            if row < snow:
                c = (246, 248, 250) if x <= cx else (212, 222, 232)
            cv.put(x, y, c)


def mountains(cv):
    for lon, lat, half in MOUNTAINS:
        x, y = project(lon, lat)
        snow = 2 if lat >= 35.8 else 0
        mountain(cv, int(x), int(y), half // 2 + 2, (108, 140, 98), (140, 170, 116), snow)


def fuji(cv):
    x, y = project(*FUJI)
    cx, cy = int(x), int(y) + 4
    for row in range(13):
        span = 1 + row * 10 // 12
        for xx in range(cx - span, cx + span + 1):
            c = (120, 146, 188) if xx >= cx else (150, 176, 214)
            if row < 5 or (row == 5 and (xx - cx) % 2 == 0):
                c = (250, 252, 255) if xx <= cx else (214, 224, 238)
            cv.put(xx, cy - 12 + row, c)


def trees(cv):
    for lon, lat in TREES:
        x, y = project(lon, lat)
        x, y = int(x), int(y)
        for dx, dy in ((0, -2), (-1, -1), (0, -1), (1, -1), (-1, 0), (0, 0), (1, 0)):
            cv.put(x + dx, y + dy, (96, 140, 86) if dx >= 0 else (118, 160, 98))
        cv.put(x, y + 1, (120, 90, 64))


def frame(cv):
    for x in range(W):
        for y in (0, H - 1):
            cv.put(x, y, shade(cv.get(x, y), 0.85))
    for y in range(H):
        for x in (0, W - 1):
            cv.put(x, y, shade(cv.get(x, y), 0.85))


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def png_bytes(px):
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in px)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", len(px[0]), len(px), 8, 6, 0, 0, 0)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header)
    return data + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def write_imageset(root, name, px):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(px))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def draw():
    cv = Canvas()
    land, lake = masks()
    sea(cv, land)
    ground(cv, land, lake)
    mountains(cv)
    trees(cv)
    fuji(cv)
    frame(cv)
    return cv


def main(argv):
    out = Path(argv[0])
    cv = draw()
    out.mkdir(parents=True, exist_ok=True)
    if out.suffix == ".xcassets":
        contents = out / "Contents.json"
        if not contents.exists():
            contents.write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
        write_imageset(out, "map_back", cv.px)
        return
    (out / "map_back.png").write_bytes(png_bytes(cv.px))
    big = [[p for p in row for _ in range(3)] for row in cv.px for _ in range(3)]
    (out / "map_preview.png").write_bytes(png_bytes(big))


if __name__ == "__main__":
    main(sys.argv[1:])
