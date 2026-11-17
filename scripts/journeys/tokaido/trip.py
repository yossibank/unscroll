import math
from artlib.trip_kit import H, Layer, W, cedar, cobble, dirt, fuji, grass, machiya, maple, noise, pine, ridge, roofs, shade, water, wave


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
