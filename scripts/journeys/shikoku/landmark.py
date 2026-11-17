import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, draw, forest_color, ground, mix, noise, pine, profile, reflect, shade, sky, water


def sea(cv, top, bottom, far, near, seed=4):
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


def swirl(cv, cx, cy, rx, ry, turns=2.4):
    foam, deep = (240, 250, 252), (22, 78, 128)
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            u, v = (x - cx) / rx, (y - cy) / ry
            d = math.hypot(u, v)
            if d > 1:
                continue
            a = math.atan2(v, u) + d * turns * math.tau * 0.5
            band = math.sin(a * 2) * 0.5 + 0.5
            if d < 0.16:
                cv.put(x, y, mix(deep, (4, 30, 70), 0.5), tint=False)
            elif band > 0.78 or d > 0.93:
                cv.put(x, y, foam if d > 0.4 else mix(foam, deep, 0.35), tint=False)
            else:
                cv.put(x, y, mix(cv.get(x, y), deep, 0.35 * (1 - d) + 0.1), tint=False)


def naruto():
    cv = Canvas("day")
    sky(cv, 54)
    cloud(cv, 36, 14, 6)
    cloud(cv, 118, 24, 5)
    profile(cv, lambda x: 50 - 4 * math.sin(x * 0.05) if x < 30 else None, 56, forest_color((66, 128, 90)), 0, 30)
    profile(cv, lambda x: 48 - 5 * math.sin((W - x) * 0.07) if x > 134 else None, 56, forest_color((66, 128, 90)), 134, W)
    sea(cv, 54, H, (126, 196, 220), (20, 94, 156))
    steel, steel_dark, cable = (212, 70, 66), (150, 44, 46), (80, 84, 96)
    deck = 52
    towers = (38, 122)
    for tx in towers:
        for y in range(18, deck + 4):
            for dx in (0, 1, 2):
                cv.put(tx + dx, y, steel if dx < 2 else steel_dark)
            for dx in (9, 10, 11):
                cv.put(tx + dx - 5, y, steel if dx < 11 else steel_dark)
        for y in range(24, deck, 9):
            for x in range(tx, tx + 7):
                cv.put(x, y, steel_dark)
        for x in range(tx - 1, tx + 8):
            cv.put(x, 18, steel_dark)
    for x in range(0, W):
        cv.put(x, deck, (232, 232, 226), tint=False)
        cv.put(x, deck + 1, (120, 124, 132), tint=False)
        cv.put(x, deck + 2, (80, 84, 92), tint=False)
    left, right = towers[0] + 3, towers[1] + 3
    for x in range(0, W):
        if x < left:
            y = int(20 + (left - x) * 0.45)
        elif x > right:
            y = int(20 + (x - right) * 0.45)
        else:
            t = (x - left) / (right - left)
            y = int(20 + (deck - 26) * (1 - (2 * t - 1) ** 2))
        cv.put(x, y, cable, tint=False)
        if left <= x <= right and (x - left) % 5 == 0:
            for yy in range(y + 1, deck):
                cv.put(x, yy, mix(cable, (255, 255, 255), 0.4), tint=False)
    for tx in towers:
        for y in range(deck + 3, H):
            if y % 2 == 0:
                cv.put(tx + 1, y, (170, 190, 200), tint=False)
    swirl(cv, 46, 82, 30, 11)
    swirl(cv, 118, 88, 26, 9)
    swirl(cv, 146, 70, 10, 4, turns=1.6)
    return cv


def katsurahama():
    cv = Canvas("morning")
    sky(cv, 46)
    disc(cv, 120, 30, 8, (255, 236, 190), glow=(255, 220, 170))
    cloud(cv, 40, 14, 6)
    sea(cv, 46, H, (108, 190, 214), (24, 104, 162))
    for x in range(0, 56):
        top = 38 + int(5 * math.sin(x * 0.07) + (56 - x) * 0.08)
        for y in range(top, 60):
            cv.put(x, y, (60, 112, 84) if noise(x // 2, y // 2, 1) > 0.25 else (44, 90, 70))
    for x in range(118, W):
        top = 52 - int(6 * math.sin((x - 118) * 0.05))
        for y in range(top, 62):
            cv.put(x, y, (66, 120, 88) if noise(x // 2, y // 2, 2) > 0.25 else (48, 96, 72))
    sand, sand_dark = (244, 228, 184), (222, 200, 150)
    foam = (240, 250, 250)
    for x in range(W):
        shore = 62 + int(16 * (1 - ((x - 80) / 80) ** 2))
        for y in range(shore, H):
            cv.put(x, y, sand if noise(x, y, 5) > 0.12 else sand_dark)
        cv.put(x, shore - 1, foam, tint=False)
        cv.put(x, shore - 2, mix(foam, (126, 200, 222), 0.5), tint=False)
        if x % 3:
            cv.put(x, shore - 4, mix(foam, (126, 200, 222), 0.6), tint=False)
    pine(cv, 22, 66, 40)
    pine(cv, 44, 62, 30)
    pine(cv, 140, 70, 44, flip=True)
    pine(cv, 154, 62, 30, flip=True)
    return cv


def shimanto():
    cv = Canvas("day")
    sky(cv, 50)
    cloud(cv, 30, 12, 6)
    cloud(cv, 126, 20, 5)
    profile(cv, lambda x: 36 + 8 * math.sin(x * 0.04 + 1) + 3 * math.sin(x * 0.16), 60, forest_color((70, 128, 96)))
    profile(cv, lambda x: 48 + 6 * math.sin(x * 0.06 + 0.2) + 2 * math.sin(x * 0.2), 60, forest_color((46, 100, 72)))
    for x in range(W):
        for y in range(56, 62):
            cv.put(x, y, (84, 142, 90) if noise(x // 2, y, 3) > 0.2 else (60, 112, 72))
    water(cv, 62, H, (26, 128, 142))
    for y in range(66, H):
        for x in range(W):
            if noise(x // 3, y // 2, 8) > 0.94:
                cv.put(x, y, mix(cv.get(x, y), (110, 210, 200), 0.5), tint=False)
    concrete, concrete_dark, edge = (214, 212, 204), (160, 158, 152), (236, 234, 228)
    layer = {}
    deck_y = 62
    for x in range(6, 154):
        layer[(x, deck_y)] = edge
        layer[(x, deck_y + 1)] = concrete
        layer[(x, deck_y + 2)] = concrete
        layer[(x, deck_y + 3)] = concrete_dark
    for px in range(14, 150, 34):
        for y in range(deck_y + 4, 78):
            for k in range(6):
                layer[(px + k, y)] = concrete if k < 4 else concrete_dark
        for k in range(6):
            layer[(px + k, 77)] = (90, 90, 88)
    for x in range(6, 154, 1):
        gap = (x - 14) % 34
        if 6 <= gap < 28:
            sag = int(4 * math.sin((gap - 6) / 22 * math.pi))
            pass
    draw(cv, layer)
    reflect(cv, layer, 78, 62, H, (26, 128, 142), strength=0.5)
    for x in range(W):
        for y in range(88, H):
            if noise(x, y, 6) > 0.86 and (x + y) % 2 == 0:
                cv.put(x, y, (180, 176, 164))
    for x in range(0, 40):
        for y in range(90 - x // 4, H):
            cv.put(x, y, (156, 150, 138) if noise(x, y, 1) > 0.3 else (128, 122, 112))
    pine(cv, 14, 96, 36)
    pine(cv, 144, 98, 30, flip=True)
    return cv


def dogo():
    cv = Canvas("evening")
    sky(cv, 70)
    cloud(cv, 30, 14, 6)
    cloud(cv, 130, 22, 5)
    profile(cv, lambda x: 58 + 6 * math.sin(x * 0.05) + 2 * math.sin(x * 0.2), 86, forest_color((44, 88, 70)))
    ground(cv, 84, (176, 164, 140), seed=5)
    for y in range(84, H):
        for x in range(W):
            if noise(x // 3, y // 2, 3) > 0.7:
                cv.put(x, y, (150, 138, 116))
    wood, wood_dark, plaster = (138, 92, 62), (96, 62, 44), (236, 228, 208)
    tile, tile_dark, tile_light = (74, 78, 90), (52, 54, 66), (118, 124, 138)

    def roof(cx, y, half, rise):
        for k in range(rise):
            span = half - k * (half - 4) // rise
            for x in range(cx - span - 2, cx + span + 3):
                c = tile_light if k == rise - 1 else tile if (x + k) % 5 else tile_dark
                cv.put(x, y - k, c)
        for x in range(cx - half - 4, cx + half + 5):
            cv.put(x, y + 1, tile_dark)

    def wall(x0, x1, y0, y1, windows):
        for y in range(y0, y1):
            for x in range(x0, x1):
                c = wood if (x - x0) % 4 else wood_dark
                if y < y0 + 2:
                    c = plaster
                cv.put(x, y, c)
        for x in windows:
            for y in range(y0 + 4, y1 - 3):
                for xx in range(x, x + 4):
                    cv.put(xx, y, (252, 206, 120) if (xx + y) % 5 else (236, 160, 80))

    wall(28, 132, 70, 86, (36, 48, 60, 90, 102, 114, 124))
    roof(80, 70, 56, 5)
    wall(56, 104, 54, 70, (62, 74, 86, 94))
    roof(80, 54, 34, 6)
    wall(66, 94, 40, 54, (72, 84))
    roof(80, 40, 22, 6)
    wall(74, 86, 28, 34, ())
    for y in range(26, 34):
        for x in range(74, 87):
            cv.put(x, y, (240, 232, 210) if y > 28 else (210, 70, 56))
    for k in range(7):
        for x in range(72 + k, 89 - k):
            cv.put(x, 26 - k, tile if k % 2 else tile_light)
    for y in range(12, 20):
        cv.put(80, y, (80, 70, 70))
    for k in range(4):
        for x in range(78 + k // 2, 83 - k // 2):
            cv.put(x, 20 + k, (246, 246, 242))
    for lx in (22, 40, 120, 138):
        for y in range(88, 96):
            cv.put(lx, y, (70, 50, 40))
        for y in range(80, 88):
            for x in range(lx - 3, lx + 4):
                cv.put(x, y, (232, 64, 52) if (x + y) % 6 else (255, 196, 90), tint=False)
        for x in range(lx - 3, lx + 4):
            cv.put(x, 79, (60, 40, 40))
    for x in range(52, 108):
        for y in range(86, 92):
            cv.put(x, y, (196, 180, 150) if (x + y) % 7 else (170, 154, 126))
    return cv


def shimanami():
    cv = Canvas("day")
    sky(cv, 50)
    cloud(cv, 34, 14, 6)
    cloud(cv, 120, 24, 5)
    sea(cv, 50, H, (120, 196, 222), (28, 112, 170))
    for x in range(0, 70):
        top = 44 + int(6 * math.sin(x * 0.07) + abs(x - 28) * 0.12)
        for y in range(top, 54):
            cv.put(x, y, (70, 132, 92) if noise(x // 2, y // 2, 1) > 0.25 else (52, 104, 76))
    for x in range(100, W):
        top = 40 + int(7 * math.sin((x - 100) * 0.06) + abs(x - 128) * 0.1)
        for y in range(top, 54):
            cv.put(x, y, (62, 122, 88) if noise(x // 2, y // 2, 2) > 0.25 else (46, 96, 72))
    for x in range(70, 100):
        top = 48 + int(3 * math.sin((x - 70) * 0.2))
        for y in range(top, 54):
            cv.put(x, y, (84, 140, 98))
    white, white_dark, steel = (244, 246, 248), (180, 188, 198), (90, 98, 112)
    deck = 56
    for x in range(W):
        cv.put(x, deck, white, tint=False)
        cv.put(x, deck + 1, white_dark, tint=False)
        cv.put(x, deck + 2, steel, tint=False)
    towers = (44, 116)
    for tx in towers:
        for y in range(14, deck + 3):
            for dx in (0, 1, 2):
                cv.put(tx + dx, y, white if dx < 2 else white_dark, tint=False)
            for dx in (8, 9, 10):
                cv.put(tx + dx, y, white if dx < 10 else white_dark, tint=False)
        for y in (24, 38):
            for x in range(tx, tx + 11):
                cv.put(x, y, white_dark, tint=False)
        for y in range(deck + 3, 70):
            for dx in range(-1, 12):
                cv.put(tx + dx, y, (200, 204, 210), tint=False)
    left, right = towers[0] + 5, towers[1] + 5
    for x in range(0, W):
        if x < left:
            y = int(14 + (left - x) * 0.3)
        elif x > right:
            y = int(14 + (x - right) * 0.3)
        else:
            t = (x - left) / (right - left)
            y = int(14 + (deck - 24) * (1 - (2 * t - 1) ** 2))
        cv.put(x, y, steel, tint=False)
        if (x - left) % 4 == 0 and y < deck - 1:
            for yy in range(y + 1, deck):
                cv.put(x, yy, (222, 226, 232), tint=False)
    layer = {}
    for tx in towers:
        for y in range(14, deck):
            layer[(tx, y)] = white
            layer[(tx + 9, y)] = white
    reflect(cv, layer, deck + 4, deck + 4, H, (28, 112, 170), strength=0.4)
    boat = {}
    bx, by = 100, 84
    for x in range(-8, 9):
        for y in range(0, 3 - abs(x) // 4):
            boat[(bx + x, by + y)] = (240, 240, 236) if y == 0 else (190, 60, 56)
    for y in range(-8, 0):
        for x in range(0, (y + 9) // 2 + 1):
            boat[(bx + 1 + x, by + y)] = (252, 252, 250)
    draw(cv, boat, tint=False)
    for x in range(88, 113):
        cv.put(x, by + 3, (240, 250, 252), tint=False)
    return cv


def konpira():
    cv = Canvas("morning")
    sky(cv, 40)
    cloud(cv, 28, 10, 5)
    cloud(cv, 134, 14, 5)
    profile(cv, lambda x: 22 + 6 * math.sin(x * 0.04) + 2 * math.sin(x * 0.18), H, forest_color((52, 108, 80)))
    for x in range(W):
        for y in range(60, H):
            cv.put(x, y, (46, 98, 72) if noise(x // 2, y // 2, 4) > 0.25 else (34, 80, 62))
    for x in list(range(0, 36)) + list(range(124, W)):
        for y in range(34, 60):
            if noise(x // 2, y // 2, 5) > 0.18:
                cv.put(x, y, (40, 94, 70))
    stone, stone_dark, stone_light = (200, 196, 184), (150, 146, 136), (230, 226, 214)
    top, bottom = 46, H
    for y in range(top, bottom):
        t = (y - top) / (bottom - top)
        half = 8 + 32 * t
        for x in range(int(80 - half), int(80 + half) + 1):
            row = (y - top) // 3
            c = stone_light if (y - top) % 3 == 0 else stone if (x + row) % 9 else stone_dark
            cv.put(x, y, c)
        edge = int(half)
        cv.put(80 - edge, y, stone_dark)
        cv.put(80 + edge, y, stone_dark)
    for y in range(top, bottom):
        t = (y - top) / (bottom - top)
        half = 8 + 32 * t
        cv.put(int(80 - half) - 1, y, (90, 84, 78))
        cv.put(int(80 + half) + 1, y, (90, 84, 78))
    for lantern_y, scale in ((60, 1), (74, 2), (90, 3)):
        t = (lantern_y - top) / (bottom - top)
        half = 8 + 32 * t
        for sign in (-1, 1):
            lx = int(80 + sign * (half + 4 + scale))
            for y in range(lantern_y, lantern_y + 3 + scale * 2):
                for x in range(lx - scale - 1, lx + scale + 2):
                    cv.put(x, y, (176, 170, 158) if x * sign <= lx * sign else (140, 134, 124))
            for x in range(lx - scale - 2, lx + scale + 3):
                cv.put(x, lantern_y - 1, (110, 104, 98))
            cv.put(lx, lantern_y + 1 + scale, (252, 214, 120))
    red, red_dark, tile, tile_dark = (206, 62, 48), (150, 42, 38), (90, 100, 112), (62, 70, 82)
    for y in range(34, 46):
        for x in range(60, 101):
            cv.put(x, y, (240, 232, 214) if (x - 60) % 8 else (170, 154, 128))
    for y in range(40, 46):
        for x in range(74, 87):
            cv.put(x, y, (62, 40, 36))
    for x in range(58, 103):
        cv.put(x, 33, red)
        cv.put(x, 32, red_dark)
    for k in range(9):
        for x in range(56 + k * 2, 105 - k * 2):
            cv.put(x, 31 - k, tile if (x + k) % 4 else tile_dark)
    for x in range(78, 83):
        cv.put(x, 22, (240, 214, 110))
    for x in range(62, 99, 12):
        for y in range(34, 40):
            cv.put(x, y, red_dark)
    return cv


SCENES = {
    "naruto": naruto,
    "katsurahama": katsurahama,
    "shimanto": shimanto,
    "dogo": dogo,
    "shimanami": shimanami,
    "konpira": konpira,
}
