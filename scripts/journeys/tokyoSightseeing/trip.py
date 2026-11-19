import math
from artlib.trip_kit import H, Layer, W, cobble, dirt, grass, mix, noise, pine, shade, water


def rect(layer, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1):
            layer.put(x, y, c)


def skyline(layer, base, color, seed, low, high, haze=0.0):
    haze_color = (216, 234, 240)
    x, i = 0, 0
    while x < W:
        bw = 12 + int(noise(i, 0, seed) * 14)
        top = base - (low + int(noise(i, 1, seed) * (high - low)))
        body = mix(color, haze_color, haze)
        for y in range(top, base):
            for xx in range(x, min(W, x + bw)):
                c = body if (xx - x) % 6 else shade(body, 0.94)
                if (y - top) % 5 == 2 and (xx - x) % 3 == 1 and y > top + 2:
                    c = shade(body, 0.84)
                layer.put(xx, y, c)
        x += bw + int(noise(i, 2, seed) * 3)
        i += 1


def lantern(layer, x, y, size=6):
    for yy in range(y, y + size):
        t = (yy - y) / size
        hw = int(2 + 2 * math.sin(math.pi * t))
        for xx in range(x - hw, x + hw + 1):
            c = (222, 54, 44) if xx <= x + hw // 2 else (170, 34, 34)
            if yy in (y, y + size - 1):
                c = (46, 40, 40)
            layer.put(xx, yy, c)
    layer.put(x, y - 1, (46, 40, 40))


def ginkgo(layer, cx, cy, r):
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 2, cx + r + 3):
            if ((x - cx) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 > 0.88 + 0.25 * noise(x, y, 6):
                continue
            n = noise(x // 2, y // 2, cx)
            c = (238, 196, 56) if n < 0.5 else (252, 224, 96) if n < 0.8 else (214, 164, 40)
            layer.put(x, y, c)
    for y in range(cy + r - 2, cy + r + 10):
        layer.put(cx, y, (92, 62, 48))
        layer.put(cx + 1, y, (70, 48, 38))


def sakura(layer, cx, cy, r):
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 2, cx + r + 3):
            if ((x - cx) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 > 0.88 + 0.25 * noise(x, y, 6):
                continue
            n = noise(x // 2, y // 2, cx)
            c = (250, 190, 206) if n < 0.5 else (255, 222, 230) if n < 0.8 else (232, 150, 176)
            layer.put(x, y, c)
    for y in range(cy + r - 2, cy + r + 10):
        layer.put(cx, y, (92, 62, 48))
        layer.put(cx + 1, y, (70, 48, 38))


def shops(layer, base, widths):
    x = 0
    for i, w in enumerate(widths):
        h = 16 + int(noise(i, 1, 5) * 6)
        top = base - h
        wood = (150, 104, 72) if i % 2 else (176, 128, 90)
        for y in range(top, base):
            for xx in range(x, x + w):
                c = wood if (xx - x) % 4 else shade(wood, 0.84)
                if top + 6 < y < top + 14 and 2 < xx - x < w - 3:
                    c = (230, 214, 176) if (xx - x) % 6 else (96, 70, 54)
                layer.put(xx, y, c)
        for k in range(4):
            for xx in range(x - 2 + k, x + w + 2 - k):
                layer.put(xx, top - k, (66, 72, 82) if k < 3 else (112, 120, 130))
        for xx in range(x - 2, x + w + 2):
            layer.put(xx, top + 1, (46, 50, 60))
        lantern(layer, x + w // 2, top + 4, 7)
        x += w + 2


def tower(layer, cx, top, bottom, half, colors, hollow=False):
    light, dark = colors
    for y in range(top, bottom):
        hw = half(y)
        for x in range(int(cx - hw), int(cx + hw) + 1):
            edge = abs(x - cx) >= hw - 1.2
            brace = (x + y) % 5 == 0 or (x - y) % 5 == 0
            if hollow and not (edge or brace):
                continue
            layer.put(x, y, light if x <= cx else dark)


def kokyo():
    far, mid, near = Layer(), Layer(), Layer()
    skyline(far, 150, (150, 168, 190), 4, 22, 70, haze=0.35)
    skyline(far, 160, (120, 142, 168), 7, 12, 38, haze=0.2)
    wall = (184, 180, 168)
    for y in range(140, 162):
        shift = (y // 5) * 7
        for x in range(W):
            c = wall
            if y % 5 == 0 or (x + shift) % 13 == 0:
                c = shade(wall, 0.72)
            elif noise(x, y, 5) > 0.9:
                c = mix(wall, (230, 226, 214), 0.5)
            mid.put(x, y, c)
    grass(mid, 138, 141, (120, 160, 96))
    plaster, roof = (240, 238, 228), (92, 132, 118)
    cx = 210
    rect(mid, cx - 20, 118, cx + 21, 138, plaster)
    for x in range(cx - 15, cx + 16, 10):
        rect(mid, x, 124, x + 5, 130, (70, 70, 78))
    for k in range(7):
        rect(mid, cx - 26 + k, 110 + k, cx + 27 - k, 111 + k, roof if k < 6 else (62, 98, 90))
    rect(mid, cx - 10, 96, cx + 11, 110, plaster)
    for k in range(9):
        rect(mid, cx - 14 + k, 88 + k, cx + 15 - k, 89 + k, roof if k < 8 else (62, 98, 90))
    for x in (40, 110, 280):
        pine(mid, x, 140, 40)
    grass(mid, 162, 168, (96, 140, 80))
    dirt(near, 168, 186, (212, 200, 174))
    grass(near, 186, H, (92, 140, 78))
    ginkgo(near, 70, 150, 26)
    ginkgo(near, 250, 156, 22)
    return far, mid, near


def asakusa():
    far, mid, near = Layer(), Layer(), Layer()
    skyline(far, 150, (156, 170, 190), 11, 20, 60, haze=0.35)
    for tier in range(5):
        y = 120 - tier * 10
        half = 16 - tier * 2
        rect(far, 214 - half, y, 214 + half, y + 7, (214, 110, 84))
        for k in range(4):
            rect(far, 214 - half - 3 + k, y - 4 + k, 214 + half + 3 - k, y - 3 + k, (76, 84, 94))
    rect(far, 213, 52, 215, 68, (226, 196, 90))
    shops(mid, 168, [24, 28, 22, 26, 30, 24, 22, 26, 24, 28, 22, 26])
    cobble(near, 168, H)
    for x in range(30, W, 80):
        rect(near, x, 138, x + 3, 200, (96, 70, 52))
        lantern(near, x + 1, 130, 12)
    for x in range(0, W, 80):
        for k in range(0, 80, 4):
            near.put(x + k, 132 + int(3 * math.sin(math.pi * k / 80)), (46, 40, 40))
    return far, mid, near


def skytree():
    far, mid, near = Layer(), Layer(), Layer()
    skyline(far, 150, (150, 166, 190), 13, 20, 54, haze=0.35)
    lit, dark = (232, 240, 248), (170, 184, 212)

    def half(y):
        if y < 36:
            return 1
        if y < 70:
            return 2
        return 2.5 + ((y - 70) / 80) ** 1.7 * 10

    tower(far, 220, 24, 150, half, (lit, dark))
    for y0, hw, h in ((52, 8, 5), (64, 6, 4)):
        rect(far, 220 - hw, y0, 220 + hw, y0 + h, (206, 218, 232))
        rect(far, 220 - hw, y0 + h - 1, 220 + hw, y0 + h, (110, 122, 156))
    for x in range(W):
        for y in range(142, 160):
            far.put(x, y, (170, 190, 212) if y % 4 else (186, 204, 222))
    x = 0
    for i, w in enumerate([22, 26, 20, 28, 24, 22, 26, 24, 22, 26, 20, 28]):
        h = 20 + int(noise(i, 4, 5) * 10)
        top = 166 - h
        wall = (232, 226, 212) if i % 2 else (206, 196, 178)
        rect(mid, x, top, x + w, 166, wall)
        for yy in range(top + 4, 164, 6):
            for xx in range(x + 3, x + w - 3, 6):
                rect(mid, xx, yy, xx + 3, yy + 3, (96, 120, 150))
        for k in range(5):
            rect(mid, x - 2 + k, top - k, x + w + 2 - k, top - k + 1, (178, 92, 70) if k % 2 else (150, 70, 56))
        x += w + 2
    grass(mid, 164, 168, (110, 150, 90))
    dirt(near, 168, 186, (206, 194, 166))
    grass(near, 186, H, (96, 144, 80))
    for x in range(4, W, 12):
        rect(near, x, 172, x + 2, 186, (230, 232, 236))
    rect(near, 0, 172, W, 174, (230, 232, 236))
    sakura(near, 60, 150, 26)
    sakura(near, 250, 154, 24)
    return far, mid, near


def odaiba():
    far, mid, near = Layer(), Layer(), Layer()
    skyline(far, 126, (150, 166, 192), 17, 14, 40, haze=0.4)
    water(far, 126, 150, (64, 126, 176), (150, 206, 226))
    steel = (214, 220, 232)
    for tx in (70, 240):
        rect(far, tx - 2, 76, tx + 2, 138, steel)
        rect(far, tx - 3, 76, tx + 3, 78, steel)
    rect(far, 0, 128, W, 131, (190, 198, 214))
    for x in range(0, W, 8):
        rect(far, x, 131, x + 2, 138, (150, 160, 182))
    for x in range(W):
        t = ((x - 70) % 170) / 170
        y = int(114 - 36 * (2 * t - 1) ** 2)
        far.put(x, y, steel)
        if x % 5 == 0:
            for yy in range(y + 1, 128):
                far.put(x, yy, (176, 186, 206))
    water(mid, 150, 168, (40, 120, 178), (140, 206, 226))
    for y in range(152, 168, 5):
        for x in range((y * 7) % 23, W, 23):
            for k in range(4):
                mid.put(x + k, y, (240, 252, 252))
    cobble(near, 168, 186, light=(214, 204, 188), dark=(196, 186, 170), joint=(160, 150, 136))
    grass(near, 186, H, (92, 144, 82))
    for x in range(0, W, 8):
        rect(near, x, 160, x + 1, 172, (240, 242, 246))
    rect(near, 0, 160, W, 162, (240, 242, 246))
    for x in (40, 160, 280):
        rect(near, x, 110, x + 3, 172, (76, 84, 96))
        rect(near, x - 4, 106, x + 8, 112, (255, 240, 180))
        rect(near, x - 5, 104, x + 9, 106, (76, 84, 96))
    for x in (100, 220):
        pine(near, x, 206, 50)
    return far, mid, near


def tokyotower():
    far, mid, near = Layer(), Layer(), Layer()
    skyline(far, 150, (152, 166, 190), 19, 16, 50, haze=0.4)
    orange, white = (232, 96, 56), (250, 246, 240)

    def half(y):
        if y < 60:
            return 0.6
        if y < 76:
            return 1.5 + (y - 60) / 16 * 4
        if y < 82:
            return 10
        return 5 + ((y - 82) / 68) ** 1.4 * 22

    cx = 90
    for y in range(24, 150):
        hw = half(y)
        tone = orange if ((y - 24) // 8) % 2 == 0 else white
        for x in range(int(cx - hw), int(cx + hw) + 1):
            edge = abs(x - cx) >= hw - 1.4
            brace = (x + y) % 6 == 0 or (x - y) % 6 == 0
            if y < 60 or (76 <= y < 82) or edge or brace:
                far.put(x, y, tone if x <= cx else shade(tone, 0.85))
    rect(far, cx - 6, 60, cx + 7, 64, (250, 220, 150))
    skyline(mid, 168, (96, 112, 140), 23, 18, 44)
    skyline(mid, 168, (120, 136, 160), 29, 10, 28)
    grass(mid, 164, 168, (110, 150, 90))
    dirt(near, 168, 186, (212, 200, 174))
    grass(near, 186, H, (86, 138, 76))
    for x in (50, 170, 270):
        pine(near, x, 206, 56)
    ginkgo(near, 230, 150, 20)
    return far, mid, near


SCENES = {
    "kokyo": kokyo,
    "asakusa": asakusa,
    "skytree": skytree,
    "odaiba": odaiba,
    "tokyotower": tokyotower,
}
