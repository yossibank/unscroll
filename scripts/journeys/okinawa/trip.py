import math
from artlib.trip_kit import H, Layer, W, dirt, grass, mix, noise, ridge, shade, water, wave


def palm(layer, x0, base, height, lean=1):
    trunk, trunk_dark = (132, 104, 78), (96, 74, 56)
    for i in range(height):
        x = x0 + int(lean * 6 * (i / height) ** 2)
        layer.put(x, base - i, trunk if i % 4 else trunk_dark)
        layer.put(x + 1, base - i, trunk_dark)
    top_x, top_y = x0 + lean * 6, base - height
    green, green_dark = (52, 134, 76), (30, 94, 56)
    for angle in (-2.9, -2.3, -1.7, -1.1, -0.5, 0.1, 0.6):
        for i in range(16):
            ax = top_x + int(math.cos(angle + math.pi) * i * 0.9)
            ay = top_y + int(math.sin(angle) * i * 0.5 + i * i * 0.05)
            layer.put(ax, ay, green if i % 3 else green_dark)
            layer.put(ax, ay + 1, green_dark)


def akagawara(layer, base, widths):
    x = 0
    for i, w in enumerate(widths):
        h = 14 + int(noise(i, 1, 5) * 5)
        top = base - h
        wall = (236, 230, 214)
        for y in range(top, base):
            for xx in range(x, x + w):
                c = wall if (xx - x) % 7 else shade(wall, 0.9)
                if top + 4 < y < top + 9 and 2 < xx - x < w - 3:
                    c = (96, 70, 54) if (xx - x) % 5 else (60, 44, 36)
                layer.put(xx, y, c)
        for k in range(6):
            for xx in range(x - 2 + k, x + w + 2 - k):
                layer.put(xx, top - k, (200, 84, 56) if (xx + k) % 3 else (226, 118, 84))
        for xx in range(x - 2, x + w + 2):
            layer.put(xx, top + 1, (150, 56, 44))
        sx = x + w // 2
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, -1), (1, -1), (0, -2)):
            layer.put(sx + dx, top - 6 + dy, (236, 196, 120))
        for xx in range(x - 3, x + w + 3):
            for y in range(base - 5, base):
                layer.put(xx, y, (170, 166, 150) if (y + xx // 3) % 3 else (130, 126, 114))
        x += w + 5


def fukugi(layer, x0, base, height):
    trunk, trunk_dark = (120, 92, 66), (82, 62, 46)
    for y in range(base - height // 2, base + 1):
        for k in range(3):
            layer.put(x0 + k, y, trunk if k < 2 else trunk_dark)
    r = height // 2
    cy = base - height + r // 2
    for y in range(cy - r, cy + r):
        for x in range(x0 - r, x0 + r + 1):
            if ((x - x0) / r) ** 2 + ((y - cy) / (r * 0.8)) ** 2 > 1 + 0.15 * noise(x, y, 6) - 0.1:
                continue
            n = noise(x // 2, y // 2, x0)
            c = (30, 86, 54) if n < 0.4 else (44, 112, 66) if n < 0.85 else (110, 166, 80)
            layer.put(x, y, c)


def cane(layer, top, bottom):
    for x in range(W):
        h = 30 + int(noise(x // 3, 0, 5) * 14)
        y0 = top - h + 30
        for y in range(y0, bottom):
            r = noise(x, y, 9)
            c = (112, 160, 64) if r > 0.15 else (84, 128, 52)
            if (y - y0) % 7 == 0 and x % 3 == 0:
                c = (170, 176, 84)
            layer.put(x, y, c)
        for k in range(1, 7):
            side = 1 if x % 2 else -1
            layer.put(x + side * k, y0 + k // 2 + 1, (140, 190, 80))
            layer.put(x + side * k, y0 + k // 2 + 2, (96, 144, 56))
        layer.put(x, y0 - 1, (236, 232, 214))
        layer.put(x, y0 - 2, (214, 210, 198))


def shurijo():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 100, ((12, 1, 0.4), (5, 3, 1.0)), (104, 150, 140), 150, haze=0.3)
    ridge(far, 118, ((8, 2, 1.7), (3, 6, 0.4)), (74, 126, 96), 150, haze=0.12)
    red, roof = (214, 62, 46), (196, 78, 54)
    cx, y = 236, 112
    for y0 in range(y - 12, y):
        for x in range(cx - 18, cx + 19):
            far.put(x, y0, red if (x - cx) % 6 not in (0, 1) else (160, 40, 36))
    for k in range(4):
        for x in range(cx - 22 + k, cx + 23 - k):
            far.put(x, y - 12 - k, roof)
    for y0 in range(y - 22, y - 16):
        for x in range(cx - 10, cx + 11):
            far.put(x, y0, red)
    for k in range(4):
        for x in range(cx - 14 + k, cx + 15 - k):
            far.put(x, y - 22 - k, roof)
    akagawara(mid, 166, [22, 26, 20, 24, 28, 22, 20, 26, 24, 20, 22, 26, 24, 22])
    grass(mid, 166, 168, (96, 140, 80))
    dirt(near, 168, 186, (214, 204, 178))
    grass(near, 186, H, (86, 134, 76))
    for x in range(10, W, 46):
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, -1), (0, 1)):
            near.put(x + dx, 196 + dy + int(noise(x, 0, 3) * 6), (230, 58, 62) if (dx, dy) != (0, 0) else (250, 200, 80))
    palm(near, 80, 206, 54, lean=1)
    palm(near, 240, 206, 48, lean=-1)
    return far, mid, near


def sefautaki():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 104, ((10, 1, 1.2), (4, 4, 0.6)), (90, 144, 110), 150, haze=0.2)
    ridge(far, 126, ((5, 3, 0.2), (3, 7, 1.0)), (58, 112, 84), 150)
    cane(mid, 150, 168)
    dirt(near, 168, 186, (198, 176, 140))
    grass(near, 186, H, (74, 124, 70))
    for x in range(14, W, 53):
        palm(near, x, 208, 50 + int(noise(x, 2, 4) * 12), lean=1 if (x // 53) % 2 else -1)
    return far, mid, near


def manzamo():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 134, ((3, 1, 0.5), (2, 5, 1.4)), (120, 160, 170), 140, haze=0.35)
    water(far, 140, 152, (40, 110, 176), (120, 196, 220))
    water(mid, 152, 166, (60, 170, 200), (160, 226, 226))
    for x in range(W):
        top = 164 + int(wave(x, (1.5, 6, 0), (1, 13, 1)))
        for y in range(top, top + 3):
            mid.put(x, y, (250, 252, 252) if noise(x, y, 1) > 0.25 else (200, 232, 236))
        for y in range(top + 3, 168):
            mid.put(x, y, (232, 218, 184) if noise(x, y, 5) > 0.2 else (212, 196, 162))
    for x in range(0, W, 40):
        for k in range(6):
            for xx in range(x + 8 + k, x + 24 - k):
                mid.put(xx, 160 - k, (150, 128, 118) if k < 5 else (110, 160, 84))
    dirt(near, 168, 186, (232, 222, 190))
    grass(near, 186, H, (104, 152, 84))
    for x in range(20, W, 80):
        palm(near, x, 206, 46, lean=1)
    return far, mid, near


def bise():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 112, ((8, 1, 0.8), (4, 3, 0.4)), (96, 150, 128), 150, haze=0.2)
    for x in range(8, W, 30):
        fukugi(far, x, 150, 22 + int(noise(x, 0, 8) * 8))
    akagawara(mid, 164, [20, 22, 18, 24, 20, 22, 18, 24, 20, 22, 20])
    for x in range(4, W, 21):
        fukugi(mid, x, 168, 34 + int(noise(x, 1, 8) * 12))
    dirt(near, 168, 186, (236, 228, 200))
    grass(near, 186, H, (96, 144, 80))
    for x in (40, 150, 260):
        fukugi(near, x, 208, 70)
    return far, mid, near


def kourijima():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 126, ((5, 1, 0.6), (3, 4, 1.4)), (96, 150, 140), 136, haze=0.3)
    deck = (150, 160, 178)
    for x in range(W):
        far.put(x, 120, deck)
        far.put(x, 121, shade(deck, 0.8))
        far.put(x, 118, mix(deck, (255, 255, 255), 0.3))
        if x % 32 == 0:
            for y in range(122, 136):
                far.put(x, y, deck)
                far.put(x + 1, y, shade(deck, 0.8))
        arch = int(5 * math.sin(math.pi * (x % 32) / 32))
        far.put(x, 119 - arch, deck)
    water(mid, 136, 166, (24, 130, 190), (150, 226, 226))
    for y in range(140, 166, 6):
        for x in range((y * 5) % 19, W, 19):
            for k in range(4):
                mid.put(x + k, y, (240, 252, 252))
    grass(mid, 166, 168, (110, 150, 90))
    dirt(near, 168, 186, (240, 228, 190))
    grass(near, 186, H, (96, 148, 84))
    for x in range(0, W, 4):
        h = 6 + int(noise(x, 0, 5) * 8)
        for i in range(h):
            near.put(x, 209 - i, (88, 150, 70))
    palm(near, 50, 206, 56, lean=1)
    palm(near, 200, 206, 50, lean=-1)
    return far, mid, near


SCENES = {
    "shurijo": shurijo,
    "sefautaki": sefautaki,
    "manzamo": manzamo,
    "bise": bise,
    "kourijima": kourijima,
}
