import math
from artlib.trip_kit import H, Layer, W, capped, cedar, cobble, dirt, fuji, grass, mix, noise, ridge, shade, snow, water, wave


def birch(layer, x0, base, h):
    for y in range(base - h, base + 1):
        layer.put(x0, y, (238, 238, 230))
        layer.put(x0 + 1, y, (190, 190, 182))
        if noise(x0, y, 21) > 0.82:
            layer.put(x0, y, (52, 48, 46))
    for dx, dy, r in ((0, 0, 7), (-5, 5, 5), (5, 4, 5), (1, 9, 4)):
        for y in range(base - h + dy - r, base - h + dy + r):
            for x in range(x0 + dx - r, x0 + dx + r + 1):
                if ((x - x0 - dx) / r) ** 2 + ((y - base + h - dy) / (r * 0.85)) ** 2 <= 1:
                    n = noise(x // 2, y // 2, 8)
                    layer.put(x, y, (146, 188, 82) if n < 0.5 else (178, 208, 96) if n < 0.85 else (110, 160, 70))


def fence(layer, base, step=16):
    wood, dark = (146, 110, 76), (104, 76, 54)
    for x in range(0, W, step):
        for y in range(base - 8, base):
            layer.put(x, y, wood)
            layer.put(x + 1, y, dark)
    for x in range(W):
        layer.put(x, base - 6, wood)
        layer.put(x, base - 3, dark)


def cow(layer, x0, base, flip=1):
    white, black = (246, 244, 238), (50, 48, 52)
    for y in range(base - 8, base - 2):
        for x in range(x0, x0 + 13):
            c = black if (noise(x // 3, y // 3, 7) > 0.62) else white
            layer.put(x, y, c)
    for y in range(base - 10, base - 4):
        for x in range(x0 + 11 if flip > 0 else x0 - 4, x0 + 16 if flip > 0 else x0 + 2):
            layer.put(x, y, white if y > base - 9 else black)
    for x in (x0 + 1, x0 + 4, x0 + 9, x0 + 12):
        for y in range(base - 2, base):
            layer.put(x, y, (110, 100, 96))


def poplar(layer, x0, base, h):
    for y in range(base - h, base):
        half = int(2 + 2 * math.sin((y - base + h) / h * math.pi))
        for x in range(x0 - half, x0 + half + 1):
            layer.put(x, y, (190, 190, 170) if x < x0 else (150, 150, 140))
    for y in range(base, base + 3):
        layer.put(x0, y, (96, 66, 50))


def onuma():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 92, ((8, 1, 0.5), (5, 3, 1.1), (3, 7, 0.2)), (118, 134, 170), 150, haze=0.3)
    for x in range(W):
        top = int(92 - wave(x, (8, 1, 0.5), (5, 3, 1.1), (3, 7, 0.2)))
        for y in range(top, top + 3):
            far.put(x, y, (200, 208, 226))
    ridge(far, 124, ((5, 2, 1.4), (3, 5, 0.4)), (84, 132, 100), 150, haze=0.12)
    grass(mid, 146, 176, (112, 164, 90), seed=2)
    fence(mid, 164)
    for x, flip in ((40, 1), (126, -1), (212, 1), (280, -1)):
        cow(mid, x, 172, flip)
    grass(near, 176, H, (92, 144, 78), seed=5)
    for x in range(4, W, 9):
        for i in range(8 + int(noise(x, 3, 5) * 8)):
            near.put(x + i // 5, 206 - i, (236, 206, 110) if i > 10 else (110, 160, 72))
    for x in (60, 190):
        birch(near, x, 208, 70)
    return far, mid, near


def toyako():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 104, ((7, 2, 0.8), (4, 5, 0.3)), (96, 122, 150), 150, haze=0.3)
    fuji(far, 118, 50, 120, 56, 8)
    ridge(far, 126, ((4, 1, 1.0), (2, 4, 0.5)), (70, 112, 96), 150, haze=0.1)
    water(mid, 138, 168, (58, 112, 168), (130, 184, 214), seed=4)
    for x in range(W):
        top = int(134 - wave(x, (3, 1, 0.2), (2, 4, 1.1)))
        for y in range(top, 138):
            mid.put(x, y, (52, 100, 74))
    for x in range(14, W, 40):
        cedar(mid, x, 140, 14 + int(noise(x, 0, 2) * 8), (40, 84, 64))
    dirt(near, 176, 190, (196, 170, 128))
    grass(near, 190, H, (90, 140, 76), seed=3)
    grass(near, 168, 176, (100, 152, 82), seed=6)
    for x in (30, 150, 262):
        birch(near, x, 206, 66)
    return far, mid, near


def otaru():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 104, ((7, 1, 1.2), (4, 4, 0.4)), (110, 136, 164), 150, haze=0.28)
    water(far, 128, 150, (70, 126, 168), (150, 196, 214), seed=2)
    ridge(far, 122, ((3, 2, 0.6),), (92, 122, 120), 128, haze=0.15)
    stone, stone_dark, roof = (156, 112, 86), (118, 82, 64), (66, 64, 76)
    x = 0
    for i, w in enumerate((30, 26, 34, 28, 32, 28, 34, 28, 26, 28, 26)):
        h = 24 + int(noise(i, 1, 4) * 8)
        top = 154 - h
        for y in range(top, 154):
            for xx in range(x, x + w):
                mid.put(xx, y, stone_dark if noise(xx // 3, y // 2, 5) > 0.78 else stone)
        for k in range(8):
            for xx in range(x - 1 + k, x + w + 1 - k):
                mid.put(xx, top - k, roof if k < 7 else mix(roof, (255, 255, 255), 0.2))
        for wy in range(top + 6, 150, 10):
            for wx in range(x + 5, x + w - 4, 9):
                for dy in range(5):
                    mid.put(wx, wy + dy, (44, 40, 54))
                    mid.put(wx + 1, wy + dy, (44, 40, 54))
                    mid.put(wx + 2, wy + dy, (44, 40, 54))
        x += w
    water(mid, 154, 172, (46, 78, 128), (110, 156, 190), seed=3)
    cobble(near, 172, H)
    for x in range(20, W, 80):
        for y in range(144, 176):
            near.put(x, y, (40, 40, 48))
        for dx, dy in ((-1, 0), (0, 0), (1, 0), (-1, 1), (1, 1), (0, -1)):
            near.put(x + dx, 143 + dy, (255, 228, 150))
    return far, mid, near


def sapporo():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 98, ((10, 1, 0.3), (5, 3, 1.0)), (214, 226, 242), 150, haze=0.15)
    ridge(far, 122, ((4, 2, 1.5), (2, 5, 0.4)), (120, 140, 168), 150, haze=0.2)
    city = (176, 186, 204)
    for x in range(W):
        h = int(8 + 18 * noise(x // 13, 0, 8))
        for y in range(146 - h, 150):
            far.put(x, y, city if (x // 13) % 3 else shade(city, 0.9))
    for x in range(6, W, 40):
        for y in range(118, 150):
            far.put(x, y, (150, 160, 180))
        for k in range(-2, 3):
            far.put(x + k, 118, (150, 160, 180))
    snow(mid, 150, 170, 4)
    for x in range(10, W, 40):
        poplar(mid, x, 160 + int(noise(x, 2, 3) * 4), 26 + int(noise(x, 0, 1) * 8))
    snow(near, 170, H, 6)
    for x in range(W):
        for y in range(182, 196):
            if abs(y - 189 - 3 * math.sin(2 * math.pi * 2 * x / W)) < 4:
                near.put(x, y, (214, 224, 240) if noise(x, y, 5) > 0.3 else (196, 208, 228))
    for x in (60, 250):
        capped(near, x, 206, 52, (30, 64, 52))
    return far, mid, near


def furano():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 92, ((10, 1, 0.9), (6, 3, 0.1), (3, 8, 1.0)), (112, 130, 168), 150, haze=0.25)
    for x in range(W):
        top = int(92 - wave(x, (10, 1, 0.9), (6, 3, 0.1), (3, 8, 1.0)))
        for y in range(top, top + 5):
            far.put(x, y, (244, 248, 252))
    ridge(far, 124, ((5, 2, 0.6), (3, 6, 1.4)), (74, 126, 92), 150, haze=0.1)
    for y in range(138, 176):
        for x in range(W):
            top = 138 + int(3 * math.sin(2 * math.pi * 2 * x / W))
            if y < top:
                continue
            if y < 152:
                u = (x - 160) / (y - 100)
                stripe = u * 14
                frac = stripe - math.floor(stripe)
                lav = [(150, 100, 200), (176, 128, 222), (122, 78, 176)]
                c = lav[int(math.floor(stripe)) % 3] if frac > 0.3 else (84, 128, 74)
            else:
                band = (y - 152) // 4
                c = [(244, 196, 64), (230, 110, 60), (250, 246, 240), (214, 70, 110), (120, 170, 88)][band % 5]
                if noise(x, y, 5) > 0.82:
                    c = mix(c, (255, 255, 255), 0.4)
            mid.put(x, y, c)
    grass(near, 184, H, (88, 136, 76), seed=5)
    for x in range(3, W, 8):
        base = 208 - int(noise(x, 1, 3) * 6)
        for i in range(14):
            near.put(x + i // 5, base - i, (150, 96, 200) if i > 8 else (86, 128, 70))
            near.put(x + 1 + i // 5, base - i, (176, 128, 222) if i > 8 else (70, 108, 60))
    for x in (96, 230):
        birch(near, x, 210, 62)
    return far, mid, near


def asahikawa():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 94, ((12, 1, 0.4), (6, 3, 1.2), (3, 8, 0.6)), (222, 232, 246), 150, haze=0.08)
    for x in range(W):
        if noise(x, 3, 12) > 0.55:
            top = int(94 - wave(x, (12, 1, 0.4), (6, 3, 1.2), (3, 8, 0.6)))
            for y in range(top + 6, top + 12):
                far.put(x, y, (150, 170, 204))
    ridge(far, 122, ((5, 2, 0.5), (3, 5, 1.0)), (92, 122, 126), 150, haze=0.15)
    for x in range(W):
        top = int(122 - wave(x, (5, 2, 0.5), (3, 5, 1.0)))
        for y in range(top, top + 4):
            far.put(x, y, (240, 246, 252))
    snow(mid, 148, 170, 4)
    for x in range(10, W, 32):
        capped(mid, x, 154 + int(noise(x, 2, 3) * 6), 24 + int(noise(x, 0, 1) * 10))
    snow(near, 170, H, 6)
    for x in range(W):
        for y in range(184, 200):
            edge = abs(y - 192 - 4 * math.sin(2 * math.pi * x / W))
            if edge < 5 and noise(x // 2, y, 9) > 0.2:
                near.put(x, y, (200, 214, 232))
    for x in (40, 180, 290):
        capped(near, x, 206, 54, (30, 64, 52))
    return far, mid, near


SCENES = {
    "onuma": onuma,
    "toyako": toyako,
    "otaru": otaru,
    "sapporo": sapporo,
    "furano": furano,
    "asahikawa": asahikawa,
}
