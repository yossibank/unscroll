import math
from artlib.trip_kit import H, Layer, W, cedar, dirt, grass, mix, noise, pine, ridge, shade, water, wave


def mikan(layer, cx, base, r):
    trunk = (96, 66, 48)
    for y in range(base - r // 2, base + 1):
        layer.put(cx, y, trunk)
    cy = base - r - r // 3
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 1, cx + r + 2):
            if ((x - cx) / (r + 1)) ** 2 + ((y - cy) / r) ** 2 > 1 + 0.12 * noise(x, y, 6) - 0.08:
                continue
            n = noise(x // 2, y // 2, cx)
            c = (40, 108, 60) if n < 0.5 else (60, 132, 70) if n < 0.9 else (110, 170, 84)
            if noise(x, y, cx + 3) > 0.93:
                c = (250, 150, 36)
            layer.put(x, y, c)


def stone_wall(layer, top, bottom):
    for y in range(top, bottom):
        row = (y - top) // 4
        for x in range(W):
            c = (170, 164, 150) if noise((x + row * 3) // 6, row, 4) > 0.4 else (148, 142, 128)
            if (y - top) % 4 == 0 or (x + row * 3) % 6 == 0:
                c = (104, 98, 88)
            layer.put(x, y, c)


def katsurahama():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 116, ((10, 1, 0.2), (3, 5, 1.0)), (112, 170, 176), 140, haze=0.3)
    ridge(far, 126, ((6, 2, 1.4), (2, 7, 0.4)), (76, 136, 112), 140, haze=0.12)
    water(mid, 138, 168, (22, 116, 178), (128, 214, 224))
    for y in range(142, 168, 5):
        for x in range((y * 7) % 17, W, 17):
            for k in range(4):
                mid.put(x + k, y, (240, 252, 252))
    for x in range(W):
        mid.put(x, 168, (246, 232, 190))
        mid.put(x, 169, (232, 214, 168))
    dirt(near, 170, 188, (216, 206, 178))
    grass(near, 188, H, (92, 144, 80))
    for x in range(0, W, 6):
        near.put(x, 171, (150, 140, 120))
    pine(near, 52, 206, 56)
    pine(near, 232, 206, 50)
    return far, mid, near


def shimanto():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 96, ((14, 1, 0.8), (5, 3, 0.3)), (98, 152, 138), 150, haze=0.32)
    ridge(far, 116, ((10, 2, 1.9), (4, 5, 0.7)), (66, 124, 96), 150, haze=0.14)
    for x in range(6, W, 30):
        cedar(far, x + int(noise(x, 3, 3) * 14), 130 + int(noise(x, 4, 3) * 6), 22, (40, 88, 66))
    water(mid, 140, 168, (22, 126, 140), (140, 214, 204))
    for y in range(144, 168, 5):
        for x in range((y * 11) % 21, W, 21):
            for k in range(5):
                mid.put(x + k, y, (214, 244, 240))
    for x in range(0, W, 3):
        mid.put(x, 168, (156, 150, 136) if noise(x, 1, 2) > 0.3 else (126, 120, 108))
    dirt(near, 170, 188, (206, 184, 140))
    grass(near, 188, H, (80, 134, 72))
    for x in (28, 96, 188, 276):
        cedar(near, x, 206, 60 + int(noise(x, 1, 2) * 10))
    return far, mid, near


def dogo():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 100, ((10, 1, 1.0), (4, 4, 0.2)), (122, 168, 150), 150, haze=0.3)
    ridge(far, 122, ((8, 2, 0.5), (3, 6, 1.2)), (86, 144, 100), 150, haze=0.1)
    for row, (base, r) in enumerate(((148, 7), (160, 9))):
        for x in range(row * 9, W, 19 + row * 4):
            mikan(far if row == 0 else mid, x, base, r)
    grass(mid, 164, 168, (112, 156, 84))
    stone_wall(mid, 168, 174)
    dirt(near, 174, 190, (214, 196, 150))
    grass(near, 190, H, (96, 148, 80))
    for x in (40, 150, 262):
        mikan(near, x, 206, 16)
    return far, mid, near


def shimanami():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 112, ((6, 1, 0.3), (2, 6, 1.1)), (118, 176, 176), 140, haze=0.34)
    for cx, half, h in ((50, 36, 14), (150, 30, 10), (260, 40, 16)):
        for x in range(cx - half, cx + half):
            top = 122 - int(h * (1 - ((x - cx) / half) ** 2) ** 0.7)
            for y in range(top, 140):
                far.put(x, y, mix((70, 132, 96) if y > top else (110, 168, 120), (216, 234, 240), 0.1))
    white = (240, 244, 248)
    for tx in (96, 210):
        for y in range(78, 124):
            far.put(tx, y, white)
            far.put(tx + 1, y, (180, 190, 200))
    for x in range(W):
        far.put(x, 124, white)
        far.put(x, 125, (176, 186, 198))
    for x in range(96, 211):
        t = (x - 96) / 114
        y = int(80 + 36 * (1 - (2 * t - 1) ** 2))
        far.put(x, y, (150, 160, 172))
        if x % 5 == 0:
            for yy in range(y + 1, 124):
                far.put(x, yy, (212, 220, 228))
    for tx in (96, 210):
        for y in range(78, 124):
            far.put(tx - 1, y, white)
            far.put(tx + 2, y, (180, 190, 200))
    water(mid, 140, 168, (22, 112, 176), (126, 208, 226))
    for y in range(144, 168, 5):
        for x in range((y * 5) % 19, W, 19):
            for k in range(4):
                mid.put(x + k, y, (240, 252, 252))
    for x in range(W):
        mid.put(x, 168, (176, 172, 160))
    dirt(near, 170, 188, (206, 200, 186))
    for x in range(0, W, 12):
        for y in range(170, 175):
            near.put(x, y, (232, 232, 228))
    grass(near, 188, H, (92, 144, 80))
    pine(near, 60, 206, 54)
    pine(near, 254, 206, 48)
    return far, mid, near


def konpira():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 108, ((6, 1, 0.4), (3, 4, 1.3)), (118, 168, 150), 150, haze=0.3)
    cx, peak = 170, 70
    for y in range(peak, 150):
        t = (y - peak) / (150 - peak)
        hw = 3 + 72 * t ** 1.5
        for x in range(int(cx - hw), int(cx + hw) + 1):
            c = (82, 140, 98) if x < cx + (y - peak) * 0.1 else (62, 114, 82)
            if noise(x // 2, y // 2, 4) > 0.82:
                c = shade(c, 0.85)
            far.put(x, y, mix(c, (216, 234, 240), 0.14))
    for x in range(W):
        for y in range(146, 168):
            mid.put(x, y, (176, 204, 110) if (x // 4 + y // 3) % 2 else (150, 190, 98))
    for x in range(W):
        mid.put(x, 168, (112, 150, 84))
    for x in range(40, W, 90):
        for y in range(150, 168):
            for k in range(-1, 2):
                mid.put(x + k, y, (120, 100, 70))
        for k in range(-4, 5):
            mid.put(x + k, 150, (150, 124, 90))
    dirt(near, 170, 190, (218, 196, 150))
    grass(near, 190, H, (88, 140, 76))
    for x in (30, 140, 230):
        for y in range(180, 198):
            for dx in range(0, 7):
                near.put(x + dx, y, (186, 180, 166) if dx < 5 else (146, 140, 128))
        for dx in range(-1, 8):
            near.put(x + dx, 179, (110, 104, 96))
        for dx in range(2, 5):
            near.put(x + dx, 184, (236, 226, 190))
    cedar(near, 80, 206, 66)
    cedar(near, 290, 206, 58)
    return far, mid, near


SCENES = {
    "katsurahama": katsurahama,
    "shimanto": shimanto,
    "dogo": dogo,
    "shimanami": shimanami,
    "konpira": konpira,
}
