"""部屋の背景のドット絵を描く。

壁・床・家具を、180x140 px の別々の PNG に描き、アプリが重ねる。
壁は 4 種、床は 3 種。家具は腰板・窓・棚・絵はがきの紐・座布団・観葉植物である。
窓のガラスは透明にし、アプリが後ろに旅の景色を描く。絵はがき・おみやげ・相棒もアプリが置く。
置く位置は RoomScene.swift の座標とそろえる。描き方の決まりは docs/decisions/landmark.md にある。
出力先が .xcassets なら imageset を作り、そうでなければ壁と床の組ごとに 3 倍の見本を書く。

    python3 -I scripts/room-art.py <出力先>
"""
import json
import math
import struct
import sys
import zlib
from pathlib import Path

W, H = 180, 140
WALL_BOTTOM, FLOOR_TOP = 96, 100
WINDOW = (10, 12, 82, 62)
SHELF_Y, SHELF_X = 54, (98, 172)
STRING = (94, 174, 13, 4)
CUSHION = (90, 118)
OUTLINE = (74, 52, 40)


def noise(x, y, seed=0):
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


class Canvas:
    def __init__(self):
        self.px = [[(0, 0, 0, 0)] * W for _ in range(H)]

    def put(self, x, y, c):
        if 0 <= x < W and 0 <= y < H:
            self.px[int(y)][int(x)] = (*c, 255) if len(c) == 3 else c

    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1):
            for x in range(x0, x1):
                self.put(x, y, c)


def wall_plaster(cv):
    base = (240, 228, 206)
    for y in range(WALL_BOTTOM):
        for x in range(W):
            cv.put(x, y, shade(base, 0.97) if noise(x, y, 1) > 0.9 else base)


def wall_dots(cv):
    base, dot = (214, 234, 248), (255, 255, 255)
    for y in range(WALL_BOTTOM):
        for x in range(W):
            row = y // 10
            dx, dy = (x + row % 2 * 5) % 10, y % 10
            on = dx in (4, 5) and dy in (3, 4, 5, 6) or dx in (3, 6) and dy in (4, 5)
            cv.put(x, y, dot if on else base)


def wall_stripe(cv):
    base, line = (253, 232, 225), (246, 204, 190)
    for y in range(WALL_BOTTOM):
        for x in range(W):
            cv.put(x, y, line if x % 12 < 5 else base)


def wall_stars(cv):
    base, star, dust = (46, 62, 107), (246, 196, 83), (196, 206, 232)
    cv.rect(0, 0, W, WALL_BOTTOM, base)
    for y in range(2, WALL_BOTTOM - 2):
        for x in range(2, W - 2):
            n = noise(x, y, 11)
            if n > 0.994:
                for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
                    cv.put(x + dx, y + dy, star)
            elif n > 0.985:
                cv.put(x, y, dust)


def wainscot(cv):
    wood = (184, 134, 90)
    for y in range(70, WALL_BOTTOM):
        for x in range(W):
            seam = x % 12 == 0
            grain = noise(x // 2, y, 4) > 0.82
            cv.put(x, y, shade(wood, 0.78) if seam else shade(wood, 0.93) if grain else wood)
    cv.rect(0, 68, W, 70, (150, 104, 66))
    cv.rect(0, 70, W, 71, (206, 160, 112))
    cv.rect(0, WALL_BOTTOM, W, FLOOR_TOP, (112, 78, 52))
    cv.rect(0, WALL_BOTTOM, W, WALL_BOTTOM + 1, (140, 100, 68))


def floor_wood(cv):
    wood = (204, 160, 110)
    for y in range(FLOOR_TOP, H):
        row = (y - FLOOR_TOP) // 8
        for x in range(W):
            joint = (y - FLOOR_TOP) % 8 == 7 or (x + row * 37) % 60 == 0
            grain = noise(x // 3, y, 7) > 0.85
            c = shade(wood, 0.8) if joint else shade(wood, 0.95) if grain else wood
            cv.put(x, y, shade(c, 1 - (y - FLOOR_TOP) * 0.003))


def floor_tatami(cv):
    straw, edge = (201, 197, 138), (94, 107, 58)
    for y in range(FLOOR_TOP, H):
        row = (y - FLOOR_TOP) // 20
        for x in range(W):
            border = (y - FLOOR_TOP) % 20 in (18, 19) or (x + row % 2 * 45) % 90 in (0, 1)
            weave = x % 3 == 0
            c = edge if border else shade(straw, 0.92) if weave else straw
            cv.put(x, y, shade(c, 1 - (y - FLOOR_TOP) * 0.003))


def floor_tile(cv):
    light, dark, grout = (237, 230, 216), (216, 205, 182), (196, 184, 160)
    for y in range(FLOOR_TOP, H):
        for x in range(W):
            tx, ty = x % 10, (y - FLOOR_TOP) % 10
            checker = (x // 10 + (y - FLOOR_TOP) // 10) % 2
            c = grout if tx == 9 or ty == 9 else dark if checker else light
            cv.put(x, y, shade(c, 1 - (y - FLOOR_TOP) * 0.003))


def glass(cv):
    x0, y0, x1, y1 = WINDOW
    for y in range(y0 + 3, y1 - 3):
        for x in range(x0 + 3, x1 - 3):
            cv.px[y][x] = (0, 0, 0, 0)


def window(cv):
    x0, y0, x1, y1 = WINDOW
    frame, light = (150, 104, 64), (196, 150, 104)
    glass(cv)
    cv.rect(x0, y0, x1, y0 + 3, frame)
    cv.rect(x0, y1 - 3, x1, y1, frame)
    cv.rect(x0, y0, x0 + 3, y1, frame)
    cv.rect(x1 - 3, y0, x1, y1, frame)
    mid = (x0 + x1) // 2
    cv.rect(mid - 1, y0, mid + 1, y1, frame)
    cv.rect(x0, (y0 + y1) // 2 - 1, x1, (y0 + y1) // 2, frame)
    cv.rect(x0 + 1, y0 + 1, x1 - 1, y0 + 2, light)
    cv.rect(x0 - 3, y1, x1 + 3, y1 + 3, (166, 118, 76))
    cv.rect(x0 - 3, y1 + 3, x1 + 3, y1 + 4, (120, 84, 54))
    curtain = (232, 132, 112)
    for side in (0, 1):
        for y in range(y0 - 2, y1 + 6):
            width = 7 + int(2 * math.sin(y / 5))
            for i in range(width):
                x = x0 - 6 + i if side == 0 else x1 + 5 - i
                fold = (i + y // 3) % 4 == 0
                cv.put(x, y, shade(curtain, 0.86) if fold else curtain)
    cv.rect(x0 - 8, y0 - 4, x1 + 8, y0 - 2, (110, 78, 52))


def shelf(cv):
    x0, x1 = SHELF_X
    cv.rect(x0, SHELF_Y, x1, SHELF_Y + 3, (168, 118, 74))
    cv.rect(x0, SHELF_Y, x1, SHELF_Y + 1, (200, 152, 104))
    cv.rect(x0, SHELF_Y + 3, x1, SHELF_Y + 4, (112, 78, 50))
    for bx in (x0 + 6, x1 - 8):
        for i in range(5):
            cv.put(bx + i, SHELF_Y + 4 + i, (120, 84, 54))
            cv.put(bx, SHELF_Y + 4 + i, (120, 84, 54))


def garland(cv):
    x0, x1, y, sag = STRING
    for x in range(x0, x1):
        t = (x - x0) / (x1 - x0)
        cv.put(x, y + sag * math.sin(math.pi * t), (120, 92, 70))
    for x in (x0, x1 - 1):
        cv.rect(x - 1, y - 1, x + 2, y + 2, (196, 70, 60))


def cushion(cv):
    cx, top = CUSHION
    blue, light = (62, 86, 150), (96, 122, 186)
    for y in range(top, top + 14):
        inset = max(0, 3 - (y - top)) + max(0, (y - top) - 10)
        for x in range(cx - 30 + inset, cx + 30 - inset):
            edge = y == top or x in (cx - 30 + inset, cx + 29 - inset)
            cv.put(x, y, OUTLINE if edge else light if y < top + 4 else blue)
    for x in (cx - 30, cx + 29):
        cv.rect(x - 1, top + 12, x + 2, top + 16, (232, 196, 90))


def plant(cv):
    x, base = 160, 128
    pot = (196, 110, 76)
    for y in range(base - 12, base):
        inset = (y - (base - 12)) // 4
        cv.rect(x - 8 + inset, y, x + 8 - inset, y + 1, pot)
    cv.rect(x - 9, base - 13, x + 9, base - 11, shade(pot, 0.85))
    leaf = (76, 140, 84)
    for i, (dx, h) in enumerate(((-6, 14), (-2, 22), (3, 18), (7, 12), (0, 26))):
        for j in range(h):
            lx = x + dx + int((j / h) * dx * 0.6)
            cv.put(lx, base - 13 - j, shade(leaf, 0.85) if i % 2 else leaf)
            cv.put(lx + 1, base - 13 - j, leaf)


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


WALLS = {"plaster": wall_plaster, "dots": wall_dots, "stripe": wall_stripe, "stars": wall_stars}
FLOORS = {"wood": floor_wood, "tatami": floor_tatami, "tile": floor_tile}


def layer(*draws):
    cv = Canvas()
    for draw in draws:
        draw(cv)
    return cv.px


def layers():
    found = {"room_back": layer(wainscot, window, shelf, garland, cushion, plant)}
    found.update({f"room_wall_{name}": layer(draw, glass) for name, draw in WALLS.items()})
    found.update({f"room_floor_{name}": layer(draw) for name, draw in FLOORS.items()})
    return found


def stack(*images):
    out = [[(150, 196, 236, 255)] * W for _ in range(H)]
    for px in images:
        for y in range(H):
            for x in range(W):
                if px[y][x][3]:
                    out[y][x] = px[y][x]
    return out


def main(argv):
    out = Path(argv[0])
    found = layers()
    out.mkdir(parents=True, exist_ok=True)
    if out.suffix == ".xcassets":
        contents = out / "Contents.json"
        if not contents.exists():
            contents.write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
        for name, px in found.items():
            write_imageset(out, name, px)
        return
    for wall_name in WALLS:
        for floor_name in FLOORS:
            room = stack(found[f"room_wall_{wall_name}"], found[f"room_floor_{floor_name}"], found["room_back"])
            big = [[p for p in row for _ in range(3)] for row in room for _ in range(3)]
            (out / f"room_{wall_name}_{floor_name}.png").write_bytes(png_bytes(big))


if __name__ == "__main__":
    main(sys.argv[1:])
