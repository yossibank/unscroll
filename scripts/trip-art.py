"""旅の途中の景色のドット絵を描く。

次に向かう名所ごとに、遠景・中景・近景の 3 枚の層を 320x210 px の透明な PNG に描く。
どの層も横につなげて流せるように、左右の端をそろえて描く。空と時刻の光の色はアプリが描く。
絵の名前は trip_<名所>_<層>。出力先が .xcassets なら、絵ごとに imageset を作る。
そうでなければ、層を重ねた見本を書く。描き方の決まりは docs/decisions/landmark.md にある。

    python3 -I scripts/trip-art.py <出力先> [名所…]
"""
import json
import math
import struct
import sys
import zlib
from pathlib import Path

W, H = 320, 210
TAU = math.tau
HAZE = (216, 234, 240)
LAYERS = ("far", "mid", "near")


def noise(x, y, seed=0):
    x %= W
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def wave(x, *terms):
    return sum(amp * math.sin(TAU * cycles * x / W + phase) for amp, cycles, phase in terms)


class Layer:
    def __init__(self):
        self.px = [[None] * W for _ in range(H)]

    def put(self, x, y, c):
        if 0 <= y < H:
            self.px[y][int(x) % W] = c

    def get(self, x, y):
        if 0 <= y < H:
            return self.px[y][int(x) % W]
        return None


def ridge(layer, base, terms, color, until, haze=0.0):
    top_color = mix(color, (255, 255, 255), 0.15)
    for x in range(W):
        top = int(base - wave(x, *terms))
        for y in range(top, until):
            c = top_color if y == top else color
            layer.put(x, y, mix(c, HAZE, haze))


def grass(layer, top, bottom, color, seed=3):
    light, dark = mix(color, (240, 236, 190), 0.2), shade(color, 0.8)
    for y in range(top, bottom):
        for x in range(W):
            layer.put(x, y, light if y == top else dark if noise(x, y, seed) < 0.15 else color)


def cobble(layer, top, bottom, light=(152, 146, 132), dark=(132, 126, 114), joint=(92, 88, 80)):
    for y in range(top, bottom):
        row = (y - top) // 3
        for x in range(W):
            stone = light if noise((x + row * 2) // 5, row, 4) > 0.5 else dark
            layer.put(x, y, joint if (y - top) % 3 == 0 or (x + row * 2) % 5 == 0 else stone)


def dirt(layer, top, bottom, base=(204, 178, 132)):
    edge, light = shade(base, 0.86), mix(base, (255, 240, 210), 0.3)
    for y in range(top, bottom):
        for x in range(W):
            r = noise(x, y, 7)
            layer.put(x, y, edge if y in (top, bottom - 1) else light if r > 0.9 else base)


def cedar(layer, x0, base, h, color=(40, 78, 58)):
    dark, light = shade(color, 0.7), mix(color, (160, 200, 140), 0.3)
    for y in range(base - h, base + 1):
        t = (y - (base - h)) / h
        half = 1 + t * h * 0.22
        for x in range(int(x0 - half), int(x0 + half) + 1):
            c = color
            if (y - base) % 4 == 0 and abs(x - x0) > half * 0.5:
                c = dark
            elif x < x0 - half * 0.3 and noise(x, y, 2) > 0.6:
                c = light
            layer.put(x, y, c)
    for y in range(base, base + 4):
        layer.put(x0, y, (96, 66, 50))


def pine(layer, x0, base, height, needle=(44, 92, 70)):
    trunk, trunk_dark = (110, 78, 60), (78, 54, 44)
    needle_dark, needle_light = shade(needle, 0.7), mix(needle, (180, 220, 150), 0.35)
    for i in range(height):
        lean = int(math.sin(i * 0.12) * 3)
        layer.put(x0 + lean, base - i, trunk)
        layer.put(x0 + lean + 1, base - i, trunk_dark)
    s = height / 40
    for frac, w, h, shift in ((1.0, 8, 4, 0), (0.8, 11, 4, 4), (0.6, 9, 4, -4), (0.42, 6, 3, 3)):
        w, h = max(3, int(w * s)), max(2, int(h * s + 0.5))
        py = base - int(height * frac) + h
        pcx = x0 + int(math.sin(height * frac * 0.12) * 3) + shift
        for y in range(py - h, py + 1):
            for x in range(pcx - w, pcx + w + 1):
                dx, dy = (x - pcx) / w, (py - y) / h
                if dy >= 0 and dx * dx + dy * dy * 1.3 <= 1 + 0.12 * math.sin(x * 1.9):
                    if dy > 0.7 or (dy > 0.45 and (x + y) % 3 == 0):
                        c = needle_light
                    elif dy < 0.2:
                        c = needle_dark
                    else:
                        c = needle
                    layer.put(x, y, c)


def maple(layer, cx, cy, r):
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 2, cx + r + 3):
            if ((x - cx) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 > 0.88 + 0.25 * noise(x, y, 6):
                continue
            n = noise(x // 2, y // 2, cx)
            c = (226, 88, 50) if n < 0.45 else (246, 146, 60) if n < 0.75 else (186, 48, 40)
            if y < cy - r * 0.4 and n > 0.6:
                c = (255, 196, 96)
            layer.put(x, y, c)
    for y in range(cy + r - 2, cy + r + 8):
        layer.put(cx, y, (92, 62, 48))
        layer.put(cx + 1, y, (70, 48, 38))


def water(layer, top, bottom, deep, light, seed=1):
    for y in range(top, bottom):
        t = (y - top) / max(1, bottom - top)
        base = mix(light, deep, t)
        for x in range(W):
            c = base
            glint = (x + (y * 13) % 17) % 23 < 3 and y % 4 == 1 and noise(x // 23, y, seed) > 0.5
            if glint:
                c = mix(c, (255, 255, 255), 0.45)
            layer.put(x, y, c)
    for x in range(W):
        layer.put(x, top, mix(light, (255, 255, 255), 0.4))


def fuji(layer, cx, peak, base, half, snow):
    rock, rock_dark = (98, 120, 158), (76, 94, 130)
    snow_lit, snow_dark = (250, 250, 248), (202, 214, 232)
    for y in range(peak, base):
        t = (y - peak) / (base - peak)
        hw = 2 + (half - 2) * t ** 1.45
        for x in range(int(cx - hw), int(cx + hw) + 1):
            right = x > cx + (y - peak) * 0.16
            line = peak + snow + 2 * math.sin(x * 1.7) + (5 if x % 5 == 0 else 0) + (2 if x % 3 == 0 else 0)
            if y < line:
                c = snow_dark if right else snow_lit
            else:
                c = rock_dark if right else rock
                if x % 7 == 3 and y < line + 5 + (x * 3) % 5:
                    c = mix(c, snow_dark, 0.5)
            layer.put(x, y, mix(c, HAZE, 0.12))


def machiya(layer, base, roof=(58, 62, 72)):
    x, i = 0, 0
    widths = [20, 24, 18, 22, 26, 20, 24, 18, 22, 26, 20, 24, 20, 18, 18]
    for w in widths:
        h = 18 + int(noise(i, 1, 5) * 6)
        top = base - h
        wood, lattice = (120, 80, 56), (88, 58, 40)
        for y in range(top, base):
            for xx in range(x, x + w):
                c = wood
                if y > top + 8 and (xx - x) % 2 == 0:
                    c = lattice
                if top + 3 < y < top + 8 and 2 < xx - x < w - 3:
                    c = (226, 218, 200) if (xx - x) % 3 else lattice
                layer.put(xx, y, c)
        for k in range(5):
            for xx in range(x - 2 + k // 2, x + w + 2 - k // 2):
                layer.put(xx, top - k, roof if k < 4 else mix(roof, (255, 255, 255), 0.25))
        for xx in range(x - 2, x + w + 2):
            layer.put(xx, top + 8, roof)
            layer.put(xx, top + 9, mix(roof, (255, 255, 255), 0.25))
        noren = (40, 60, 110) if i % 2 else (150, 40, 40)
        for y in range(top + 10, top + 15):
            for xx in range(x + w // 2 - 3, x + w // 2 + 3):
                if not (y > top + 12 and xx % 2):
                    layer.put(xx, y, noren)
        for y in range(top + 10, top + 14):
            for xx in (x + w - 3, x + w - 2):
                layer.put(xx, y, (240, 214, 150))
        x += w
        i += 1


def roofs(layer, base, rows):
    tile, tile_light, wall = (64, 68, 78), (104, 110, 120), (220, 212, 196)
    for row in range(rows):
        y0 = base - row * 9
        offset = row * 13
        for x in range(0, W, 26):
            for k in range(8):
                for xx in range(x + offset - 13 + k, x + offset + 13 - k):
                    c = tile_light if k == 7 else tile
                    layer.put(xx, y0 - k, c)
            for y in range(y0 + 1, y0 + 4):
                for xx in range(x + offset - 10, x + offset + 10):
                    layer.put(xx, y, wall if (xx + y) % 5 else (150, 120, 90))


def ashinoko():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 82, ((14, 1, 0.3), (6, 3, 1.1)), (120, 148, 176), 150, haze=0.25)
    ridge(far, 104, ((10, 2, 1.7), (4, 5, 0.4)), (70, 112, 96), 150, haze=0.1)
    for x in range(0, W, 7):
        cedar(mid, x, 150 + int(noise(x, 0, 1) * 4), 40 + int(noise(x, 1, 1) * 12), (36, 72, 54))
    grass(mid, 150, 168, (70, 112, 70))
    cobble(near, 168, 186)
    grass(near, 186, H, (64, 104, 66))
    for x in (30, 190):
        cedar(near, x, 204, 70, (30, 62, 48))
    return far, mid, near


def miho():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 126, ((4, 2, 0.2), (2, 5, 1.0)), (130, 150, 170), 136, haze=0.3)
    fuji(far, 170, 40, 136, 130, 22)
    water(mid, 134, 160, (36, 84, 150), (110, 166, 206))
    for x in range(W):
        top = 158 + int(wave(x, (1.5, 6, 0), (1, 13, 1)))
        for y in range(top, top + 3):
            mid.put(x, y, (250, 252, 252) if noise(x, y, 1) > 0.25 else (200, 224, 236))
        for y in range(top + 3, 168):
            mid.put(x, y, (226, 212, 180) if noise(x, y, 5) > 0.2 else (206, 190, 158))
    dirt(near, 168, 186, (232, 216, 180))
    grass(near, 186, H, (96, 136, 84))
    for x in (60, 167, 274):
        pine(near, x, 206, 52)
    return far, mid, near


def hamanako():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 126, ((3, 2, 0.5), (2, 7, 1.0)), (112, 128, 150), 134, haze=0.35)
    deck = (96, 104, 120)
    for x in range(W):
        far.put(x, 118, deck)
        far.put(x, 119, shade(deck, 0.8))
        if x % 32 == 0:
            for y in range(120, 134):
                far.put(x, y, deck)
                far.put(x + 1, y, shade(deck, 0.8))
        arch = int(4 * math.sin(math.pi * (x % 32) / 32))
        far.put(x, 117 - arch, deck)
    water(mid, 134, 166, (56, 104, 140), (140, 186, 210))
    for row, (y0, step, h) in enumerate(((142, 9, 4), (150, 13, 6), (160, 17, 8))):
        for x in range(row * 5, W, step):
            for y in range(y0 - h, y0 + 1):
                mid.put(x, y, (176, 150, 104) if y > y0 - h else (210, 186, 130))
    grass(mid, 166, 168, (110, 140, 90))
    dirt(near, 168, 186)
    grass(near, 186, H, (96, 134, 80))
    for x in range(0, W, 3):
        h = 14 + int(noise(x, 0, 5) * 16)
        lean = 1 if noise(x, 1, 5) > 0.5 else 0
        for i in range(h):
            near.put(x + (lean if i > h * 0.6 else 0), 209 - i, (178, 166, 108) if i > h - 4 else (112, 124, 72))
    return far, mid, near


def nagoyajo():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 128, ((3, 1, 0.5), (2, 4, 2.0)), (128, 140, 160), 140, haze=0.35)
    city = (150, 156, 170)
    for x in range(W):
        h = int(4 + 6 * noise(x // 9, 0, 8))
        for y in range(136 - h, 140):
            far.put(x, y, city)
    cx, base = 220, 136
    for y in range(base - 8, base):
        half = 18 + (y - (base - 8)) * 0.6
        for x in range(int(cx - half), int(cx + half) + 1):
            far.put(x, y, (150, 144, 130) if (x + y) % 4 else (120, 114, 104))
    top = base - 8
    for w, hh in ((30, 6), (25, 5), (20, 5), (15, 4), (10, 5)):
        for y in range(top - hh, top):
            for x in range(cx - w // 2, cx + w // 2 + 1):
                far.put(x, y, (236, 232, 222) if x < cx + w // 4 else (206, 202, 196))
        top -= hh
        for x in range(cx - w // 2 - 3, cx + w // 2 + 4):
            far.put(x, top, (84, 150, 138))
            far.put(x, top - 1, (120, 180, 166))
        top -= 2
    for dx in (-5, 5):
        far.put(cx + dx, top, (240, 196, 70))
        far.put(cx + dx, top - 1, (240, 196, 70))
    for y in range(140, 168):
        for x in range(W):
            band = (y - 140) // 4
            if (y - 140) % 4 == 0:
                c = (150, 132, 96)
            elif band % 2:
                c = (160, 196, 210) if noise(x, y, 9) > 0.7 else (120, 168, 96)
            else:
                c = (104, 156, 84) if (x + y) % 3 else (132, 180, 100)
            mid.put(x, y, c)
    dirt(near, 168, 186)
    grass(near, 186, H, (92, 132, 80))
    for x in range(20, W, 64):
        pine(near, x, 206, 56)
    return far, mid, near


def biwako():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 96, ((16, 1, 2.0), (6, 3, 0.4)), (110, 104, 140), 150, haze=0.2)
    ridge(far, 120, ((5, 3, 0.6), (3, 7, 1.4)), (80, 110, 96), 150)
    machiya(mid, 166)
    dirt(near, 166, 186)
    grass(near, 186, H, (92, 132, 80))
    pine(near, 200, 206, 46)
    return far, mid, near


def kiyomizu():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 96, ((14, 1, 0.6), (5, 4, 1.2)), (70, 98, 90), 150, haze=0.15)
    red, roof = (226, 86, 58), (70, 58, 56)
    pcx, y = 240, 128
    for tier in range(5):
        w = 7 - tier
        for yy in range(y - 4, y):
            for x in range(pcx - w + 2, pcx + w - 1):
                far.put(x, yy, red)
        y -= 4
        for i in range(2):
            for x in range(pcx - w - 2 + i, pcx + w + 2 - i):
                far.put(x, y - i, roof)
        y -= 2
    for yy in range(y - 8, y):
        far.put(pcx, yy, (230, 196, 90))
    roofs(mid, 164, 4)
    cobble(near, 168, 186, (176, 160, 136), (156, 140, 118), (110, 96, 82))
    grass(near, 186, H, (86, 120, 74))
    for cx, cy, r in ((40, 176, 16), (200, 182, 14), (290, 172, 12)):
        maple(near, cx, cy, r)
    return far, mid, near


SCENES = {
    "ashinoko": ashinoko,
    "miho": miho,
    "hamanako": hamanako,
    "nagoyajo": nagoyajo,
    "biwako": biwako,
    "kiyomizu": kiyomizu,
}


def png_bytes(rows):
    h, w = len(rows), len(rows[0])
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in rows)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    return png + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def rgba(layer):
    return [[(*c, 255) if c else (0, 0, 0, 0) for c in row] for row in layer.px]


def write_imageset(root, name, layer):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(rgba(layer)))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def flatten(layers):
    sky = [(128, 184, 234), (216, 234, 240)]
    rows = [[mix(sky[0], sky[1], y / H)] * W for y in range(H)]
    for layer in layers:
        for y in range(H):
            for x in range(W):
                if layer.px[y][x]:
                    rows[y][x] = layer.px[y][x]
    return rows


def write_sheet(path, scenes):
    gap = 12
    width = W + gap * 2
    sheet = [[(246, 241, 234)] * width for _ in range(gap)]
    for layers in scenes:
        for row in flatten(layers):
            sheet.append([(246, 241, 234)] * gap + row + [(246, 241, 234)] * gap)
        sheet += [[(246, 241, 234)] * width for _ in range(gap)]
    path.write_bytes(png_bytes([[(*c, 255) for c in row] for row in sheet]))


def main(argv):
    out = Path(argv[0])
    names = argv[1:] or list(SCENES)
    out.mkdir(parents=True, exist_ok=True)
    scenes = []
    for name in names:
        layers = SCENES[name]()
        scenes.append(layers)
        for kind, layer in zip(LAYERS, layers):
            if out.suffix == ".xcassets":
                write_imageset(out, f"trip_{name}_{kind}", layer)
            else:
                (out / f"trip_{name}_{kind}.png").write_bytes(png_bytes(rgba(layer)))
    if out.suffix != ".xcassets":
        write_sheet(out / "trip_sheet.png", scenes)


if __name__ == "__main__":
    main(sys.argv[1:])
