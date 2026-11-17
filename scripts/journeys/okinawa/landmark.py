import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, draw, mix, moon, noise, shade, sky, water
from artlib.map_kit import inside


def lagoon(cv, top, bottom, far, near, seed=4):
    for y in range(top, bottom):
        t = (y - top) / max(1, bottom - top - 1)
        base = mix(far, near, t)
        for x in range(W):
            c = base
            r = noise(x // 2, y, seed)
            if r > 0.93 and y % 2 == 0:
                c = mix(c, (255, 255, 255), 0.4)
            elif r < 0.08:
                c = shade(c, 0.9)
            cv.put(x, y, c, tint=False)
    for x in range(W):
        cv.put(x, top, mix(cv.get(x, top), (255, 255, 255), 0.3), tint=False)


def palm(cv, x0, base, height, lean=1):
    trunk, trunk_dark = (132, 104, 78), (96, 74, 56)
    for i in range(height):
        x = x0 + int(lean * 5 * (i / height) ** 2)
        cv.put(x, base - i, trunk if i % 4 else trunk_dark)
        cv.put(x + 1, base - i, trunk_dark)
    top_x = x0 + int(lean * 5)
    top_y = base - height
    green, green_dark = (52, 134, 76), (30, 94, 56)
    for angle in (-2.9, -2.3, -1.7, -1.1, -0.5, 0.1, 0.6):
        for i in range(11):
            ax = top_x + int(math.cos(angle + math.pi) * i * 0.9)
            ay = top_y + int(math.sin(angle) * i * 0.5 + i * i * 0.05)
            cv.put(ax, ay, green if i % 3 else green_dark)
            cv.put(ax, ay + 1, green_dark)


def nahakuko():
    cv = Canvas("day")
    sky(cv, 52)
    cloud(cv, 38, 12, 6)
    cloud(cv, 132, 24, 5)
    for x in range(14, 52):
        top = 50 - int(3 * math.sin((x - 14) / 38 * math.pi))
        for y in range(top, 52):
            cv.put(x, y, (84, 136, 120) if y > top else (110, 160, 130))
    lagoon(cv, 52, 72, (96, 190, 214), (36, 128, 186))
    plane = {}
    px, py = 112, 30
    for x in range(-14, 15):
        half = 2 if abs(x) < 10 else 1
        for y in range(-half + 1, half + 1):
            plane[(px + x, py + y)] = (246, 248, 250) if y <= 0 else (204, 212, 224)
    for x in range(-10, 11):
        plane[(px + x, py + 1)] = (62, 118, 190) if abs(x) < 8 else (204, 212, 224)
    for i in range(9):
        for k in range(3):
            plane[(px - 2 + i // 2, py - 2 - i + k)] = (232, 238, 244)
            plane[(px - 2 + i // 2, py + 3 + i - k)] = (204, 212, 224)
    for i in range(6):
        plane[(px - 12 - i // 2, py - 1 - i)] = (214, 74, 60)
        plane[(px - 11 - i // 2, py - 1 - i)] = (214, 74, 60)
    draw(cv, plane, tint=False)
    for x in range(W):
        for y in range(72, H):
            cv.put(x, y, (96, 148, 84) if noise(x, y, 3) > 0.12 else (78, 128, 70))
    for y in range(72, H):
        half = 6 + (y - 72) * 3.0
        for x in range(int(80 - half), int(80 + half) + 1):
            edge = abs(x - 80) >= half - 1
            c = (232, 232, 224) if edge else (104, 108, 116) if noise(x, y, 6) > 0.1 else (92, 96, 104)
            cv.put(x, y, c)
        if (y - 72) // 3 % 2 == 0:
            for x in range(80 - (y - 72) // 14, 81 + (y - 72) // 14):
                cv.put(x, y, (250, 248, 232))
    tower = 138
    for y in range(58, 76):
        for x in range(tower, tower + 5):
            cv.put(x, y, (226, 226, 220) if x < tower + 3 else (190, 192, 190))
    for x in range(tower - 3, tower + 8):
        for y in range(52, 58):
            cv.put(x, y, (86, 148, 190) if y > 53 else (240, 240, 236))
    for y in range(62, 72):
        for x in range(8, 46):
            cv.put(x, y, (236, 232, 222) if y > 63 else (210, 80, 60))
    for x in range(8, 46, 5):
        for y in range(66, 70):
            cv.put(x, y, (90, 130, 170))
    palm(cv, 150, 100, 36, lean=-1)
    palm(cv, 12, 100, 30, lean=1)
    return cv


def shurijo():
    cv = Canvas("morning")
    sky(cv, 64)
    cloud(cv, 26, 14, 6)
    cloud(cv, 128, 10, 5)
    for x in range(W):
        top = 56 + int(4 * math.sin(x * 0.05) + 2 * math.sin(x * 0.17 + 1))
        for y in range(top, 80):
            cv.put(x, y, (74, 130, 92) if noise(x // 2, y // 2, 2) > 0.2 else (56, 108, 78))
    red, red_dark, gold = (214, 62, 46), (160, 40, 36), (240, 196, 84)
    tile, tile_dark, tile_light = (196, 78, 54), (150, 56, 44), (226, 118, 84)
    for y in range(52, 72):
        for x in range(50, 111):
            c = red if (x - 50) % 6 not in (0, 1) else red_dark
            if y > 66:
                c = gold if (x + y) % 3 == 0 else (200, 150, 70)
            cv.put(x, y, c)
    for x in range(58, 103):
        for y in range(60, 66):
            if (x - 58) % 9 in (3, 4, 5):
                cv.put(x, y, (66, 36, 32))
    for k in range(6):
        for x in range(42 + k, 119 - k):
            cv.put(x, 52 - k, tile if k % 2 == 0 else tile_dark)
    for x in range(44, 117):
        cv.put(x, 47, tile_light if x % 3 else tile)
    for y in range(36, 47):
        for x in range(62, 99):
            cv.put(x, y, red if (x - 62) % 6 not in (0, 1) else red_dark)
    for x in range(68, 93):
        for y in range(39, 43):
            if (x - 68) % 8 in (2, 3, 4):
                cv.put(x, y, (66, 36, 32))
    for k in range(9):
        for x in range(56 + k, 106 - k):
            cv.put(x, 36 - k, tile if k % 2 == 0 else tile_dark)
    for x in range(72, 90):
        cv.put(x, 27, tile_light)
    for side, cx in ((-1, 70), (1, 90)):
        for i in range(4):
            cv.put(cx + side * 9 + side * i // 2, 27 - i, gold)
    for y in range(24, 28):
        cv.put(80, y, gold)
    stone, stone_dark, stone_light = (222, 214, 192), (178, 168, 146), (244, 238, 220)
    for y in range(72, H):
        for x in range(0, W):
            curve = 72 + int(5 * math.sin(x * 0.055 + 0.6) ** 2)
            if y < curve:
                continue
            c = stone
            row = (y - 72) // 5
            if (y - 72) % 5 == 0 or (x + row * 7) % 14 == 0:
                c = stone_dark
            elif noise(x, y, 7) > 0.92:
                c = stone_light
            cv.put(x, y, c)
    for y in range(72, H):
        half = 8 + (y - 72) // 3
        for x in range(80 - half, 80 + half + 1):
            c = (236, 228, 206) if (y - 72) % 3 else (190, 180, 156)
            cv.put(x, y, c)
    for x in range(W):
        top = 72 + int(5 * math.sin(x * 0.055 + 0.6) ** 2)
        cv.put(x, top, stone_light)
    palm(cv, 18, 80, 30, lean=1)
    palm(cv, 144, 80, 32, lean=-1)
    for hx, hy in ((8, 94), (30, 90), (130, 92), (152, 96)):
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, -1), (0, 1)):
            cv.put(hx + dx, hy + dy, (230, 58, 62) if (dx, dy) != (0, 0) else (250, 200, 80))
    return cv


def sefautaki():
    cv = Canvas("day")
    for y in range(H):
        for x in range(W):
            r = noise(x // 2, y // 2, 5)
            cv.put(x, y, (24, 70, 52) if r < 0.45 else (36, 96, 64) if r < 0.85 else (74, 138, 80))
    gap = [(52, 100), (96, 100), (66, 30)]
    rock = [(6, 100), (8, 42), (34, 18), (74, 8), (118, 16), (150, 40), (154, 100)]
    for y in range(0, H):
        for x in range(W):
            if y < 18 or y > 100:
                continue
            if not inside(rock, x + 0.5, y + 0.5):
                continue
            r = noise(x, y, 8)
            c = (150, 140, 124) if r < 0.6 else (168, 158, 140) if r < 0.9 else (126, 118, 104)
            if (x * 3 + y) % 17 == 0:
                c = (112, 104, 92)
            if x > 110:
                c = shade(c, 0.86)
            cv.put(x, y, c)
    for y in range(8, 100):
        for x in range(W):
            if not inside(gap, x + 0.5, y + 0.5):
                continue
            if y < 74:
                t = y / 74
                c = mix((120, 176, 230), (212, 232, 244), t)
            else:
                c = mix((70, 170, 200), (30, 112, 170), (y - 74) / 26)
            cv.put(x, y, c)
    for x in range(58, 80):
        for y in range(70, 76):
            if inside(gap, x + 0.5, y + 0.5):
                cv.put(x, y, (66, 128, 96) if y < 73 else (84, 150, 124))
    for y in range(8, 101):
        for x in range(W):
            if inside(gap, x + 0.5, y + 0.5):
                continue
            if inside(gap, x - 0.5, y + 0.5) or inside(gap, x + 1.5, y + 0.5):
                cv.put(x, y, (60, 56, 50))
    for x in range(6, 150, 3):
        top = 14 + int(abs(x - 78) * 0.34)
        for dy in range(4):
            cv.put(x, top + dy, (42, 110, 64) if (x + dy) % 2 else (70, 150, 78))
    for fx in (10, 36, 112, 134):
        for i in range(10):
            ax = fx + int(i * 0.8)
            ay = 98 - i * 2 + int(i * i * 0.08)
            cv.put(ax, ay, (92, 168, 84))
            cv.put(ax - 1, ay + 1, (60, 128, 66))
    for x in range(W):
        for y in range(92, H):
            if noise(x, y, 11) > 0.55:
                cv.put(x, y, (176, 164, 140) if y % 2 else (150, 138, 116))
    return cv


def manzamo():
    cv = Canvas("evening")
    sky(cv, 62)
    cloud(cv, 120, 14, 6)
    cloud(cv, 30, 24, 5)
    disc(cv, 124, 60, 7, (255, 220, 150), glow=(255, 190, 120))
    for y in range(62, H):
        t = (y - 62) / (H - 62)
        base = mix((120, 90, 130), (24, 62, 112), t)
        for x in range(W):
            c = base
            glow = max(0.0, 1 - abs(x - 124 + math.sin(y * 0.9) * 3) / (3 + t * 14))
            if glow > 0 and noise(x, y, 9) > 0.35:
                c = mix(c, (255, 206, 140), glow * 0.8)
            elif noise(x // 2, y, 4) > 0.94:
                c = mix(c, (255, 232, 200), 0.4)
            cv.put(x, y, c, tint=False)
    for x in range(W):
        cv.put(x, 62, mix(cv.get(x, 62), (255, 226, 180), 0.4), tint=False)

    def top(x):
        if x < 66:
            return 42 + int(2 * math.sin(x * 0.2))
        return 42 + int(((x - 66) / 66) ** 2 * 18)

    def bottom(x):
        if x < 82:
            return 100
        if x < 112:
            return 56 + int(((x - 82) / 30) ** 2 * 6)
        return 88

    for x in range(0, 134):
        t = top(x)
        b = bottom(x)
        if x > 112:
            t = top(x) + int(((x - 112) / 22) ** 2 * 6)
        for y in range(t, b):
            r = noise(x, y, 12)
            c = (150, 126, 120) if r < 0.6 else (176, 148, 140) if r < 0.88 else (116, 96, 98)
            if x > 100 or y > 80:
                c = shade(c, 0.78)
            if (y - t) < 3:
                c = (92, 140, 78) if noise(x, y, 3) > 0.3 else (120, 168, 90)
            cv.put(x, y, c, tint=False)
    for x in range(86, 112):
        for y in range(bottom(x) - 1, bottom(x) + 1):
            cv.put(x, y, (96, 76, 80), tint=False)
    for x in range(0, 62):
        if noise(x, 2, 14) > 0.55:
            for y in range(36, 42):
                cv.put(x, y, (96, 144, 74), tint=False)
    for x in range(0, 66, 11):
        for dy in range(5):
            cv.put(x, 38 - dy, (60, 110, 62), tint=False)
    for x in range(W):
        for y in range(88, H):
            if x < 86 and y > 84:
                continue
            if noise(x // 2, y, 6) > 0.9:
                cv.put(x, y, (255, 240, 220), tint=False)
    return cv


def bise():
    cv = Canvas("day")
    for y in range(H):
        for x in range(W):
            r = noise(x // 2, y // 2, 4)
            cv.put(x, y, (30, 86, 54) if r < 0.4 else (44, 112, 66) if r < 0.82 else (96, 160, 76))
    for y in range(8, 50):
        for x in range(W):
            d = ((x - 80) / 14) ** 2 + ((y - 38) / 11) ** 2
            if d < 1:
                cv.put(x, y, mix((250, 250, 226), (170, 220, 200), d), tint=False)
    for x in range(72, 90):
        for y in range(32, 46):
            if noise(x, y, 5) > 0.7 and (x + y) % 2 == 0:
                cv.put(x, y, (60, 130, 80))
    for y in range(46, H):
        half = 5 + (y - 46) * 1.3
        for x in range(int(80 - half), int(80 + half) + 1):
            r = noise(x, y, 7)
            c = (240, 230, 200) if r > 0.2 else (222, 210, 176)
            if abs(x - 80) > half - 2:
                c = (200, 188, 156)
            cv.put(x, y, c)
    for px, py, w in ((60, 70, 6), (96, 62, 5), (44, 90, 8), (110, 84, 7), (80, 56, 3), (78, 96, 9)):
        for y in range(py - 2, py + 2):
            for x in range(px - w, px + w):
                if ((x - px) / w) ** 2 + ((y - py) / 2) ** 2 < 1:
                    cv.put(x, y, (112, 176, 70), tint=False)
    for i in range(6):
        t = i / 5
        yb = 52 + int(48 * t ** 1.3)
        off = 7 + (yb - 46) * 1.3 + 2
        wd = 2 + int(5 * t)
        for side in (-1, 1):
            tx = int(80 + side * off)
            for y in range(max(0, yb - 22 - int(40 * t)), yb + 1):
                for k in range(wd):
                    c = (120, 92, 66) if k < wd - 1 else (82, 62, 46)
                    if noise(tx + k, y, 8) > 0.88:
                        c = (156, 124, 90)
                    cv.put(tx - wd // 2 + k, y, c)
            for k in range(wd + 4):
                cv.put(tx - wd // 2 - 2 + k, yb + 1, (92, 70, 52))
            for dy in range(-5, 3):
                cv.put(tx + side * (wd + 1 + abs(dy) // 2), yb + dy, (120, 92, 66))
    for x in range(W):
        for y in range(0, 22):
            r = noise(x // 2, y // 2, 13)
            if r < 0.6:
                cv.put(x, y, (24, 76, 48) if r < 0.3 else (36, 98, 58))
    return cv


def kourijima():
    cv = Canvas("night")
    sky(cv, 48)
    moon(cv, 28, 16)
    cloud(cv, 120, 12, 5)
    for x in range(96, W):
        top = 38 + int(((x - 128) / 32) ** 2 * 8) - int(5 * math.sin((x - 96) / 64 * math.pi))
        for y in range(top, 49):
            cv.put(x, y, (46, 100, 76) if noise(x // 2, y, 3) > 0.25 else (34, 80, 62))
    water(cv, 48, H, (14, 74, 110))
    for y in range(52, H, 2):
        half = 2 + (y - 48) * 0.18
        start = int(28 - half + noise(y, 3, 2) * 4)
        for x in range(start, start + int(half * 1.6)):
            cv.put(x, y, mix(cv.get(x, y), (240, 230, 190), 0.55), tint=False)

    def deck(x):
        return 86 - int(x / 118 * 28) - int(7 * math.sin(math.pi * min(x, 118) / 118))

    layer = {}
    for x in range(0, 112):
        y = deck(x)
        layer[(x, y)] = (186, 196, 210)
        layer[(x, y + 1)] = (150, 160, 178)
        layer[(x, y + 2)] = (96, 106, 126)
        layer[(x, y - 2)] = (150, 160, 178) if x % 2 == 0 else (120, 132, 150)
        if x % 14 == 3:
            for k in range(y + 3, y + 14 + (x // 10)):
                layer[(x, k)] = (112, 124, 146)
                layer[(x + 1, k)] = (84, 94, 116)
    draw(cv, layer, tint=False)
    for x in range(3, 112, 8):
        y = deck(x)
        for dy in (-4, -3):
            cv.put(x, y + dy, (255, 238, 170), tint=False)
        cv.put(x, y - 2, (200, 188, 140), tint=False)
        cv.put(x, y + 8, (255, 224, 150), tint=False)
    return cv


SCENES = {
    "nahakuko": nahakuko,
    "shurijo": shurijo,
    "sefautaki": sefautaki,
    "manzamo": manzamo,
    "bise": bise,
    "kourijima": kourijima,
}
