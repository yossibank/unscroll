import math
from artlib.trip_kit import H, Layer, W, cedar, cobble, dirt, fuji, grass, maple, mix, noise, pine, ridge, shade, water, wave


def blossom(layer, cx, cy, r):
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 2, cx + r + 3):
            if ((x - cx) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 > 0.88 + 0.25 * noise(x, y, 6):
                continue
            n = noise(x // 2, y // 2, cx)
            layer.put(x, y, (248, 196, 212) if n < 0.5 else (236, 160, 186) if n < 0.8 else (255, 226, 232))
    for y in range(cy + r - 2, cy + r + 8):
        layer.put(cx, y, (92, 62, 48))
        layer.put(cx + 1, y, (70, 48, 38))


def gassho(layer, cx, base, w, h):
    thatch, thatch_dark, thatch_light = (176, 148, 96), (122, 100, 66), (210, 186, 128)
    for y in range(base - h // 3, base):
        for x in range(cx - w // 2 + 3, cx + w // 2 - 2):
            layer.put(x, y, (96, 68, 52) if (x + y) % 5 else (66, 46, 38))
    for wx in (cx - w // 4, cx + w // 6):
        for y in range(base - h // 3 + 4, base - 3):
            for x in range(wx, wx + 4):
                layer.put(x, y, (236, 228, 200))
    top = base - h
    for y in range(top, base - h // 4):
        t = (y - top) / (h * 0.75)
        half = 1 + t * (w / 2 + 5)
        for x in range(int(cx - half), int(cx + half) + 1):
            r = noise(x, y, 7)
            c = thatch_light if (y + x // 3) % 6 == 0 else thatch if r > 0.2 else thatch_dark
            if x > cx + half * 0.5:
                c = shade(c, 0.82)
            layer.put(x, y, c)


def torii(layer, cx, top, bottom, w):
    red, dark, black = (224, 70, 50), (164, 46, 40), (44, 36, 36)
    for x in range(cx - w - 3, cx + w + 4):
        lift = 1 if abs(x - cx) > w else 0
        layer.put(x, top - lift, black)
        layer.put(x, top + 1 - lift, red if x < cx + w // 2 else dark)
    nuki = top + (bottom - top) // 4
    for x in range(cx - w + 1, cx + w):
        layer.put(x, nuki, red)
        layer.put(x, nuki + 1, dark)
    for y in range(top + 2, nuki):
        layer.put(cx, y, red)
    for side in (-1, 1):
        px = cx + side * (w - 4)
        for y in range(top + 2, bottom + 1):
            for k in range(3):
                layer.put(px + k, y, red if k < 2 else dark)


def tomioka():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 90, ((14, 2, 0.4), (7, 5, 1.0), (3, 11, 0.2)), (112, 134, 166), 150, haze=0.25)
    ridge(far, 116, ((6, 3, 1.4), (3, 8, 0.7)), (70, 112, 92), 150, haze=0.1)
    for row in range(4):
        y0 = 140 + row * 7
        for x in range(W):
            for y in range(y0, y0 + 5):
                mid.put(x, y, (88, 140, 70) if (x // 3 + row) % 2 else (70, 118, 60))
            mid.put(x, y0 + 5, (120, 96, 66))
    brick, mortar, roof = (178, 82, 62), (226, 206, 186), (86, 90, 102)
    for y in range(120, 140):
        for x in range(180, 270):
            mid.put(x, y, mortar if (y - 120) % 3 == 2 or (x + (y // 3) * 4) % 8 == 7 else brick)
    for i in range(8):
        for x in range(176 + i, 274 - i):
            mid.put(x, 119 - i, roof if i < 7 else (150, 154, 164))
    for y in range(96, 120):
        for x in range(262, 267):
            mid.put(x, y, brick if x < 265 else (140, 60, 48))
    dirt(near, 168, 186)
    grass(near, 186, H, (86, 128, 72))
    for x in (40, 150, 280):
        cedar(near, x, 206, 66, (34, 70, 52))
    return far, mid, near


def fujisan():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 126, ((4, 2, 0.4), (2, 6, 1.0)), (130, 150, 176), 140, haze=0.3)
    fuji(far, 160, 34, 140, 140, 24)
    ridge(mid, 138, ((4, 3, 0.2), (2, 9, 0.8)), (46, 88, 70), 150)
    for x in range(0, W, 9):
        cedar(mid, x, 148 + int(noise(x, 0, 2) * 3), 22 + int(noise(x, 1, 2) * 8), (36, 74, 56))
    water(mid, 150, 168, (46, 90, 150), (130, 180, 214))
    dirt(near, 168, 186, (214, 190, 146))
    grass(near, 186, H, (90, 130, 76))
    for cx, cy, r in ((50, 178, 14), (180, 182, 13), (280, 176, 12)):
        maple(near, cx, cy, r)
    return far, mid, near


def shirakawago():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 80, ((18, 1, 0.8), (8, 3, 0.5), (3, 9, 1.2)), (150, 170, 196), 150, haze=0.2)
    for x in range(W):
        top = int(80 - wave(x, (18, 1, 0.8), (8, 3, 0.5), (3, 9, 1.2)))
        for y in range(top, top + 10):
            far.put(x, y, (246, 248, 252) if noise(x, y, 3) > 0.15 else (216, 226, 240))
    ridge(far, 118, ((6, 2, 1.0), (3, 6, 0.3)), (64, 104, 90), 150, haze=0.1)
    for x in range(0, W, 7):
        cedar(far, x, 130 + int(noise(x, 0, 1) * 4), 14 + int(noise(x, 1, 1) * 8), (40, 78, 62))
    for y in range(146, 168):
        for x in range(W):
            band = (y - 146) // 4
            if (y - 146) % 4 == 0:
                c = (130, 112, 76)
            else:
                c = (150, 196, 96) if (x // 5 + band) % 2 else (112, 164, 78)
            mid.put(x, y, c)
    gassho(mid, 70, 146, 44, 40)
    gassho(mid, 168, 146, 52, 46)
    gassho(mid, 256, 146, 40, 36)
    dirt(near, 168, 186, (214, 192, 150))
    grass(near, 186, H, (96, 136, 80))
    for x in (30, 130, 228):
        cedar(near, x, 206, 64, (32, 66, 52))
    return far, mid, near


def nara():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 112, ((10, 1, 0.6), (4, 3, 0.2)), (104, 150, 104), 150, haze=0.15)
    red, roof = (226, 86, 58), (70, 58, 56)
    pcx, y = 230, 132
    for tier in range(5):
        w = 8 - tier
        for yy in range(y - 5, y):
            for x in range(pcx - w + 2, pcx + w - 1):
                far.put(x, yy, red)
        y -= 5
        for i in range(2):
            for x in range(pcx - w - 3 + i, pcx + w + 3 - i):
                far.put(x, y - i, roof)
        y -= 2
    for yy in range(y - 9, y):
        far.put(pcx, yy, (230, 196, 90))
    grass(mid, 142, 168, (112, 164, 92))
    for x in range(0, W, 11):
        cedar(mid, x, 146, 24 + int(noise(x, 3, 2) * 10), (44, 86, 64))
    for dx, dy in ((70, 154), (180, 158), (270, 152)):
        for k in range(10):
            for j in range(4):
                mid.put(dx + k, dy + j, (178, 122, 70) if j < 3 else (132, 88, 50))
        for k in range(5):
            mid.put(dx + 10, dy - k, (178, 122, 70))
            mid.put(dx + 11, dy - k, (178, 122, 70))
        for k in range(4):
            mid.put(dx + 12 + k, dy - 5, (178, 122, 70))
        for lx in (1, 2, 7, 8):
            for ly in range(4, 9):
                mid.put(dx + lx, dy + ly, (132, 88, 50))
    dirt(near, 168, 186, (214, 192, 150))
    grass(near, 186, H, (100, 150, 84))
    for cx, cy, r in ((44, 176, 15), (210, 182, 13), (292, 174, 12)):
        maple(near, cx, cy, r)
    return far, mid, near


def himejijo():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 112, ((4, 2, 0.5), (2, 6, 1.4)), (128, 150, 160), 140, haze=0.35)
    wall, wall_shade, roof, roof_light = (250, 248, 242), (214, 214, 214), (96, 100, 110), (150, 154, 164)
    cx, base = 160, 136
    for y in range(base - 8, base):
        half = 24 + (y - (base - 8)) * 0.7
        for x in range(int(cx - half), int(cx + half) + 1):
            far.put(x, y, (154, 148, 134) if (x + y) % 4 else (124, 118, 108))
    top = base - 8
    for w, hh in ((34, 6), (28, 6), (22, 5), (16, 5), (10, 5)):
        for y in range(top - hh, top):
            for x in range(cx - w // 2, cx + w // 2 + 1):
                far.put(x, y, wall if x < cx + w // 4 else wall_shade)
        top -= hh
        for x in range(cx - w // 2 - 4, cx + w // 2 + 5):
            far.put(x, top, roof)
            far.put(x, top - 1, roof_light)
        top -= 2
    for sx, sw in ((cx - 52, 14), (cx + 52, 12)):
        for y in range(base - 14, base):
            for x in range(sx - sw // 2, sx + sw // 2 + 1):
                far.put(x, y, wall if x < sx else wall_shade)
        for i in range(3):
            for x in range(sx - sw // 2 - 2 + i, sx + sw // 2 + 3 - i):
                far.put(x, base - 15 - i, roof if i < 2 else roof_light)
    for y in range(140, 168):
        for x in range(W):
            if y < 150:
                c = (158, 152, 138) if (x + (y // 3) * 3) % 8 else (122, 116, 104)
                if (y - 140) % 3 == 0:
                    c = (118, 112, 100)
            else:
                t = (y - 150) / 18
                c = mix((110, 160, 176), (62, 112, 140), t)
                if (x + (y * 13) % 17) % 23 < 3 and y % 4 == 1:
                    c = mix(c, (255, 255, 255), 0.4)
            mid.put(x, y, c)
    dirt(near, 168, 186, (216, 194, 150))
    grass(near, 186, H, (96, 140, 82))
    for cx2, cy, r in ((36, 176, 16), (170, 184, 14), (284, 174, 14)):
        blossom(near, cx2, cy, r)
    return far, mid, near


def itsukushima():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 90, ((16, 1, 0.9), (6, 3, 1.5)), (74, 112, 112), 140, haze=0.25)
    ridge(far, 112, ((6, 2, 0.1), (3, 6, 1.2)), (60, 100, 88), 140, haze=0.1)
    water(mid, 134, 168, (40, 98, 150), (120, 176, 206))
    torii(mid, 200, 122, 156, 20)
    torii(mid, 70, 138, 160, 9)
    for x in range(W):
        top = 160 + int(wave(x, (1.5, 6, 0), (1, 13, 1)))
        for y in range(top, top + 3):
            mid.put(x, y, (250, 252, 252) if noise(x, y, 1) > 0.25 else (200, 224, 236))
        for y in range(top + 3, 168):
            mid.put(x, y, (226, 212, 180) if noise(x, y, 5) > 0.2 else (206, 190, 158))
    dirt(near, 168, 186, (226, 210, 174))
    grass(near, 186, H, (92, 134, 80))
    for x in (50, 160, 270):
        pine(near, x, 206, 52)
    return far, mid, near


SCENES = {
    "tomioka": tomioka,
    "fujisan": fujisan,
    "shirakawago": shirakawago,
    "nara": nara,
    "himejijo": himejijo,
    "itsukushima": itsukushima,
}
