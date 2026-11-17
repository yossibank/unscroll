import math
from artlib.trip_kit import H, Layer, W, cobble, dirt, grass, mix, noise, pine, ridge, roofs, shade, water


def lantern(layer, cx, cy, r, color=(218, 60, 48)):
    dark = shade(color, 0.7)
    for y in range(cy - r - 1, cy + r + 2):
        for x in range(cx - r, cx + r + 1):
            if ((x - cx) / r) ** 2 + ((y - cy) / (r + 1)) ** 2 <= 1:
                layer.put(x, y, color if x <= cx + r // 3 else dark)
    for x in range(cx - 2, cx + 3):
        layer.put(x, cy - r - 2, (240, 200, 80))
        layer.put(x, cy + r + 2, (240, 200, 80))


def string(layer, x0, x1, y, sag, color, step, r):
    for x in range(x0, x1):
        layer.put(x, y + int(sag * math.sin((x - x0) / (x1 - x0) * math.pi)), (70, 56, 50))
    for x in range(x0 + step // 2, x1, step):
        lantern(layer, x, y + int(sag * math.sin((x - x0) / (x1 - x0) * math.pi)) + r + 3, r, color)


def house(layer, x, base, w, h, wall, roof):
    dark = shade(wall, 0.82)
    for y in range(base - h, base):
        for xx in range(x, x + w):
            c = wall if xx < x + w - 3 else dark
            if (y - base + h) % 9 in (3, 4) and (xx - x) % 8 in (2, 3, 4) and y > base - h + 3:
                c = (70, 64, 72)
            layer.put(xx, y, c)
    for i in range(5):
        for xx in range(x - 2 + i, x + w + 2 - i):
            layer.put(xx, base - h - 1 - i, roof if i < 4 else mix(roof, (255, 255, 255), 0.3))


def nankinmachi():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 100, ((16, 1, 0.6), (7, 4, 1.2), (3, 10, 0.3)), (108, 134, 160), 150, haze=0.25)
    ridge(far, 126, ((5, 3, 0.2), (2, 8, 0.9)), (92, 132, 118), 150, haze=0.1)
    for x, w, h, wall in ((6, 40, 40, (226, 200, 150)), (60, 36, 30, (206, 120, 90)), (230, 44, 44, (226, 200, 150)),
                          (278, 36, 32, (206, 120, 90))):
        house(mid, x, 168, w, h, wall, (170, 52, 44))
    red, red_dark, gold, jade, jade_dark = (210, 54, 44), (154, 36, 34), (244, 200, 80), (62, 150, 120), (36, 104, 84)
    for px in (120, 190):
        for y in range(104, 168):
            for k in range(7):
                mid.put(px + k, y, red if k < 5 else red_dark)
            if y % 14 == 0:
                for k in range(-1, 8):
                    mid.put(px + k, y, gold)
    for y in range(100, 112):
        for x in range(116, 204):
            mid.put(x, y, red if y not in (100, 111) else gold)
    for x in range(100, 220):
        lift = int(abs(x - 160) > 52) * 2 + int(abs(x - 160) > 56)
        for k in range(6):
            mid.put(x, 92 + k - lift, jade if k < 4 else jade_dark)
    for x in range(140, 180):
        for y in range(80, 92):
            mid.put(x, y, jade if y < 88 else jade_dark)
    string(mid, 0, 110, 110, 8, (218, 60, 48), 22, 4)
    string(mid, 210, W, 110, 8, (218, 60, 48), 22, 4)
    cobble(near, 168, H, (196, 186, 168), (170, 160, 142), (120, 112, 98))
    string(near, 0, W, 20, 10, (218, 60, 48), 40, 6)
    return far, mid, near


def akashi():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 118, ((8, 2, 0.4), (3, 7, 1.1)), (110, 130, 170), 150, haze=0.3)
    steel = (206, 214, 228)
    for tx in (80, 240):
        for y in range(40, 120):
            far.put(tx, y, steel)
            far.put(tx + 1, y, shade(steel, 0.8))
        for y in range(48, 120, 16):
            for k in range(-3, 5):
                far.put(tx + k, y, steel)
    for x in range(0, W):
        if 80 <= x <= 240:
            cy = int(104 - 64 * ((x - 160) / 80) ** 2)
        elif x < 80:
            cy = 40 + (80 - x) * 64 // 80
        else:
            cy = 40 + (x - 240) * 64 // 80
        far.put(x, min(cy, 104), steel)
        far.put(x, 106, steel)
        far.put(x, 107, shade(steel, 0.8))
        if x % 8 == 0 and cy < 104:
            for y in range(cy, 106):
                far.put(x, y, (176, 186, 206))
    water(mid, 124, 168, (46, 90, 150), (130, 180, 214))
    for i in range(3):
        x0 = 40 + i * 110
        for dx in range(0, 18):
            for dy in range(0, 3):
                mid.put(x0 + dx, 140 + dy, (236, 232, 224) if dy < 2 else (60, 54, 64))
        for y in range(128, 140):
            mid.put(x0 + 8, y, (236, 232, 224))
        for y in range(130, 139):
            for dx in range(0, 7 - (y - 130) // 2):
                mid.put(x0 + 9 + dx, y, (252, 244, 228))
    dirt(near, 168, 186, (226, 210, 174))
    grass(near, 186, H, (92, 134, 80))
    for x in (40, 160, 280):
        pine(near, x, 206, 52)
    return far, mid, near


def peach(layer, cx, cy, r):
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 2, cx + r + 3):
            if ((x - cx) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 > 0.88 + 0.25 * noise(x, y, 6):
                continue
            n = noise(x // 2, y // 2, cx)
            layer.put(x, y, (246, 168, 190) if n < 0.5 else (232, 128, 160) if n < 0.8 else (255, 214, 224))
    for y in range(cy + r - 2, cy + r + 8):
        layer.put(cx, y, (92, 62, 48))
        layer.put(cx + 1, y, (70, 48, 38))


def okayama():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 100, ((12, 2, 0.9), (6, 5, 0.2), (2, 12, 1.0)), (124, 148, 172), 150, haze=0.25)
    ridge(far, 124, ((5, 3, 1.4), (3, 8, 0.7)), (84, 124, 98), 150, haze=0.1)
    black, black_dark, wall = (46, 44, 52), (26, 26, 32), (246, 244, 238)
    cx = 200
    for y in range(110, 124):
        for x in range(cx - 30, cx + 31):
            mid.put(x, y, (150, 146, 138) if (y + x // 4) % 4 else (104, 100, 94))
    for tier, (w, h, upper) in enumerate(((22, 9, False), (16, 8, False), (12, 7, True))):
        top = 110 - sum(t[1] + 3 for t in ((22, 9), (16, 8), (12, 7))[:tier])
        for y in range(top - h, top):
            for x in range(cx - w, cx + w + 1):
                mid.put(x, y, wall if upper else black if x < cx + w * 0.4 else black_dark)
        for i in range(3):
            for x in range(cx - w - 4 + i, cx + w + 5 - i):
                mid.put(x, top - h - i, black if i < 2 else (86, 84, 96))
    for row in range(4):
        y0 = 142 + row * 6
        for x in range(W):
            for y in range(y0, y0 + 4):
                mid.put(x, y, (112, 164, 76) if (x // 3 + row) % 2 else (88, 140, 64))
            mid.put(x, y0 + 4, (128, 100, 70))
    dirt(near, 168, 186, (214, 190, 146))
    grass(near, 186, H, (90, 130, 76))
    for cx2, cy, r in ((50, 176, 14), (170, 180, 13), (284, 176, 13)):
        peach(near, cx2, cy, r)
    return far, mid, near


def onomichi():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 112, ((6, 2, 0.4), (3, 6, 1.0)), (130, 154, 182), 150, haze=0.35)
    ridge(far, 126, ((7, 3, 1.6), (3, 9, 0.2)), (96, 134, 140), 150, haze=0.2)
    water(mid, 138, 168, (50, 110, 160), (140, 190, 220))
    walls = ((236, 224, 196), (214, 196, 160), (240, 230, 210), (228, 206, 176))
    roofs_c = ((178, 96, 66), (96, 100, 112), (190, 110, 70))
    for k in range(9):
        x = 10 + k * 36
        base = 168 - (k % 3) * 2
        house(mid, x, base, 22 + (k % 2) * 6, 20 + (k * 3) % 8, walls[k % 4], roofs_c[k % 3])
    dirt(near, 168, 186, (214, 192, 150))
    for y in range(186, H):
        for x in range(W):
            step = (y - 186) // 6
            near.put(x, y, (200, 192, 174) if (y - 186) % 6 else (150, 142, 126))
            if noise(x // 2, step, 3) > 0.9:
                near.put(x, y, (176, 168, 150))
    for x in (30, 150, 270):
        pine(near, x, 206, 48)
    return far, mid, near


def hiroshima():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 104, ((10, 2, 2.0), (5, 5, 0.6), (2, 11, 1.4)), (108, 140, 130), 150, haze=0.25)
    for x in range(0, W, 24):
        h = 24 + int(noise(x, 2, 5) * 22)
        for y in range(128 - h, 150):
            for xx in range(x, x + 16):
                c = (200, 206, 218) if xx < x + 13 else (170, 176, 192)
                if (y - 128 + h) % 5 in (1, 2) and (xx - x) % 4 in (1, 2) and y > 128 - h + 2:
                    c = (110, 138, 170)
                far.put(xx, y, mix(c, (216, 234, 240), 0.25))
    roofs(mid, 168, 2)
    poles = (30, 130, 230)
    for px in poles:
        for y in range(80, 170):
            mid.put(px, y, (70, 66, 72))
        for x in range(px - 4, px + 5):
            mid.put(x, 82, (70, 66, 72))
    for x in range(W):
        mid.put(x, 90 + int(2 * math.sin(math.tau * x / W * 3)), (70, 66, 72))
    for y in range(168, H):
        for x in range(W):
            near.put(x, y, (124, 124, 132) if noise(x // 2, y, 5) > 0.2 else (110, 110, 120))
    for x in range(W):
        near.put(x, 168, (176, 176, 182))
    for rail in (180, 190):
        for x in range(W):
            near.put(x, rail, (190, 190, 198))
            near.put(x, rail + 1, (88, 88, 96))
    for x in range(0, W, 5):
        for rail in (181, 191):
            near.put(x, rail + 1, (110, 92, 74))
    for x in range(0, W, 24):
        near.put(x, 200, (232, 230, 220))
        near.put(x + 1, 200, (232, 230, 220))
        near.put(x + 2, 200, (232, 230, 220))
    return far, mid, near


def hakata():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 112, ((6, 2, 0.2), (3, 6, 0.9)), (84, 96, 136), 150, haze=0.15)
    for x in range(0, W, 20):
        h = 20 + int(noise(x, 7, 5) * 24)
        for y in range(136 - h, 150):
            for xx in range(x, x + 15):
                c = (70, 74, 112)
                if (y - 136 + h) % 4 in (1, 2) and (xx - x) % 4 in (1, 2) and y > 136 - h + 2:
                    c = (255, 218, 130) if noise(xx // 4, y // 4, x) > 0.35 else (50, 54, 88)
                far.put(xx, y, c)
    for x in range(W):
        for y in range(150, 168):
            mid.put(x, y, (84, 78, 98) if noise(x // 2, y, 6) > 0.2 else (70, 66, 86))
    awnings = ((214, 70, 56), (60, 110, 190), (236, 168, 40))
    for k in range(3):
        x0 = 20 + k * 100
        for y in range(122, 160):
            for x in range(x0, x0 + 70):
                c = (130, 88, 60) if (x + y // 4) % 6 else (84, 56, 42)
                if 132 <= y <= 148:
                    c = (255, 226, 150)
                mid.put(x, y, c)
        for i in range(6):
            for x in range(x0 - 5 + i, x0 + 75 - i):
                mid.put(x, 121 - i, awnings[k] if ((x - x0) // 5) % 2 else (246, 240, 224))
        lantern(mid, x0 + 6, 132, 4, (236, 90, 60))
        lantern(mid, x0 + 64, 132, 4, (236, 90, 60))
    cobble(near, 168, H, (112, 106, 124), (96, 90, 108), (60, 56, 72))
    for x in (60, 200, 300):
        for y in range(120, 190):
            near.put(x, y, (44, 40, 56))
        lantern(near, x, 116, 6, (236, 100, 60))
    return far, mid, near


SCENES = {
    "nankinmachi": nankinmachi,
    "akashi": akashi,
    "okayama": okayama,
    "onomichi": onomichi,
    "hiroshima": hiroshima,
    "hakata": hakata,
}
