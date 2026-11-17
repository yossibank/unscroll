import math
from artlib.trip_kit import H, Layer, W, cedar, dirt, fuji, grass, mix, noise, pine, ridge, shade, water, wave


def snow(layer, top, bottom, seed=3):
    light, base, shadow = (250, 252, 255), (232, 240, 248), (200, 214, 232)
    for y in range(top, bottom):
        for x in range(W):
            r = noise(x, y, seed)
            layer.put(x, y, light if y == top else shadow if r < 0.12 else light if r > 0.9 else base)


def capped(layer, x0, base, h, color=(36, 72, 58)):
    cedar(layer, x0, base, h, color)
    for y in range(base - h, base - h // 3):
        for x in range(x0 - 8, x0 + 9):
            if layer.get(x, y) is not None and noise(x, y, 11) > 0.45 and (x + y) % 2 == 0:
                layer.put(x, y, (246, 250, 255))


def paddies(layer, top, bottom, seed=2):
    for y in range(top, bottom):
        row = (y - top) // 6
        for x in range(W):
            edge = (y - top) % 6 == 0
            if edge:
                c = (150, 132, 92)
            elif row % 2:
                c = (150, 196, 210) if noise(x // 5, y, seed) > 0.72 else (122, 172, 92)
            else:
                c = (96, 150, 76) if (x + y) % 3 else (124, 176, 92)
            layer.put(x, y, c)


def poles(layer, base, step, h):
    wood, wire = (96, 84, 72), (70, 70, 78)
    for x in range(10, W, step):
        for y in range(base - h, base):
            layer.put(x, y, wood)
        for dx in range(-4, 5):
            layer.put(x + dx, base - h + 2, wood)
    for x in range(W):
        sag = int(2 * math.sin(math.pi * ((x - 10) % step) / step))
        layer.put(x, base - h + 3 + sag, wire)


def utsunomiya():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 90, ((10, 1, 0.8), (4, 3, 0.3)), (110, 140, 172), 150, haze=0.3)
    fuji(far, 96, 52, 146, 70, 6)
    ridge(far, 118, ((5, 2, 1.4), (3, 6, 0.2)), (84, 126, 100), 150, haze=0.12)
    paddies(mid, 150, 168)
    for x in range(14, W, 53):
        cedar(mid, x, 152, 22 + int(noise(x, 0, 1) * 8), (46, 84, 62))
    poles(mid, 160, 40, 14)
    dirt(near, 168, 182)
    grass(near, 182, H, (92, 136, 78))
    for x in range(4, W, 11):
        for i in range(10 + int(noise(x, 3, 5) * 8)):
            near.put(x + i // 5, 205 - i, (206, 196, 110) if i > 12 else (110, 150, 72))
    return far, mid, near


def sendai():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 100, ((12, 1, 1.4), (5, 4, 0.6)), (118, 144, 160), 150, haze=0.28)
    ridge(far, 122, ((5, 2, 0.2), (3, 5, 1.2)), (78, 122, 98), 150, haze=0.08)
    city = (170, 178, 192)
    for x in range(W):
        h = int(6 + 14 * noise(x // 11, 0, 8))
        for y in range(146 - h, 150):
            far.put(x, y, city if (x // 11) % 3 else shade(city, 0.88))
    for x in range(0, W, 23):
        for y in range(142, 150):
            far.put(x + 5, y, (96, 100, 112))
    water(mid, 150, 166, (70, 122, 150), (150, 196, 214))
    for x in range(12, W, 24):
        r = 9 + int(noise(x, 0, 4) * 3)
        for y in range(136 - r, 150):
            for xx in range(x - r - 2, x + r + 3):
                if ((xx - x) / (r + 2)) ** 2 + ((y - 136) / r) ** 2 <= 1 + 0.2 * noise(xx, y, 6):
                    n = noise(xx // 2, y // 2, x)
                    mid.put(xx, y, (74, 128, 70) if n < 0.5 else (98, 152, 80) if n < 0.85 else (50, 100, 60))
        for y in range(144, 150):
            mid.put(x, y, (96, 70, 52))
    dirt(near, 168, 184, (196, 176, 138))
    grass(near, 184, H, (88, 134, 76))
    for x in range(30, W, 90):
        r = 22
        for y in range(176 - r, 176 + r):
            for xx in range(x - r - 3, x + r + 4):
                if ((xx - x) / (r + 3)) ** 2 + ((y - 176) / r) ** 2 <= 1 + 0.2 * noise(xx, y, 9):
                    n = noise(xx // 2, y // 2, x + 1)
                    near.put(xx, y, (64, 118, 62) if n < 0.45 else (90, 146, 74) if n < 0.8 else (44, 90, 54))
        for y in range(176 + r - 2, 210):
            near.put(x, y, (92, 66, 50))
            near.put(x + 1, y, (68, 48, 38))
    return far, mid, near


def morioka():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 126, ((4, 2, 0.3), (2, 6, 1.0)), (126, 148, 170), 140, haze=0.3)
    fuji(far, 200, 46, 142, 96, 26)
    ridge(far, 134, ((3, 3, 1.1), (2, 8, 0.5)), (82, 122, 96), 150, haze=0.1)
    water(mid, 150, 168, (46, 104, 150), (130, 190, 214))
    for x in range(W):
        top = 148 + int(wave(x, (1.2, 4, 0.5), (0.8, 11, 2)))
        for y in range(top, 152):
            mid.put(x, y, (170, 160, 130) if noise(x, y, 2) > 0.3 else (146, 136, 110))
    dirt(near, 168, 184, (190, 172, 134))
    grass(near, 184, H, (96, 140, 80))
    for x in (46, 150, 262):
        pine(near, x, 206, 56, (46, 96, 72))
    return far, mid, near


def hachinohe():
    far, mid, near = Layer(), Layer(), Layer()
    water(far, 112, 150, (36, 94, 156), (150, 202, 224))
    for y in range(116, 150, 5):
        for x in range(W):
            if noise(x // 4, y, 8) > 0.88:
                far.put(x, y, (238, 246, 250))
    for x in range(W):
        far.put(x, 111, (214, 232, 240))
    for x in range(228, 290):
        far.put(x, 130 - (x - 228) // 12, (120, 124, 130))
        far.put(x, 131 - (x - 228) // 12, (150, 154, 160))
    for y in range(150, 168):
        for x in range(W):
            top = 150 + int(wave(x, (2.5, 3, 0.8), (1.2, 8, 0)))
            if y < top:
                continue
            if y < top + 3:
                mid.put(x, y, (250, 252, 252) if noise(x, y, 1) > 0.3 else (204, 226, 236))
            else:
                mid.put(x, y, (232, 214, 170) if noise(x, y, 5) > 0.2 else (212, 194, 152))
    for x in range(20, W, 70):
        pine(mid, x, 164, 34, (50, 100, 72))
    dirt(near, 168, 186, (204, 186, 150))
    grass(near, 186, H, (104, 146, 82))
    for x in range(6, W, 9):
        for i in range(12 + int(noise(x, 1, 6) * 12)):
            near.put(x + i // 6, 206 - i, (196, 190, 108) if i > 14 else (120, 156, 80))
    return far, mid, near


def shinaomori():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 100, ((18, 1, 0.9), (7, 3, 0.2)), (206, 220, 238), 150, haze=0.15)
    ridge(far, 122, ((6, 2, 1.6), (3, 6, 0.7)), (86, 114, 126), 150, haze=0.12)
    for x in range(W):
        top = int(122 - wave(x, (6, 2, 1.6), (3, 6, 0.7)))
        for y in range(top, top + 4):
            far.put(x, y, (240, 246, 252))
    snow(mid, 148, 168, 4)
    for x in range(10, W, 29):
        capped(mid, x, 152 + int(noise(x, 2, 3) * 6), 24 + int(noise(x, 0, 1) * 10))
    snow(near, 168, H, 6)
    for x in (44, 176, 280):
        capped(near, x, 206, 56, (30, 64, 52))
    for x in range(W):
        if noise(x, 4, 13) > 0.6:
            for y in range(168, 174):
                near.put(x, y, (220, 232, 246))
    return far, mid, near


SCENES = {
    "utsunomiya": utsunomiya,
    "sendai": sendai,
    "morioka": morioka,
    "hachinohe": hachinohe,
    "shinaomori": shinaomori,
}
