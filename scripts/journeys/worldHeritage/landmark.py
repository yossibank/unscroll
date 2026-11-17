import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, draw, forest_color, fuji, ground, mix, moon, noise, pine, profile, reflect, shade, sky, torii, water


def sugi(cv, x0, base, h, w):
    trunk, trunk_dark = (104, 72, 56), (72, 50, 40)
    needle = (38, 78, 60)
    dark, light = shade(needle, 0.7), mix(needle, (170, 210, 140), 0.3)
    top = base - h
    for y in range(top, base + 1):
        t = (y - top) / h
        half = 1 + t * w
        if t > 0.86:
            half = 1
        for x in range(int(x0 - half), int(x0 + half) + 1):
            if t > 0.86:
                cv.put(x, y, trunk if x <= x0 else trunk_dark)
                continue
            r = noise(x, y, 4)
            c = needle
            if (y - top) % 5 == 0 and abs(x - x0) > half * 0.4:
                c = dark
            elif x < x0 - half * 0.3 and r > 0.55:
                c = light
            elif x > x0 + half * 0.4 and r < 0.4:
                c = dark
            cv.put(x, y, c)


def nikko():
    cv = Canvas("morning")
    sky(cv, 50)
    cloud(cv, 124, 12, 6)
    profile(cv, lambda x: 28 + 10 * math.sin(x * 0.03 + 1) + 3 * math.sin(x * 0.13), 70, forest_color((60, 98, 84)))
    for x in range(-4, W + 6, 9):
        sugi(cv, x, 80, 34 + int(noise(x, 0, 3) * 14), 4)
    stone, stone_dark, stone_light = (166, 160, 148), (124, 118, 108), (196, 190, 178)
    for y in range(74, 84):
        for x in range(30, 130):
            c = stone_dark if (y - 74) % 3 == 0 or (x + (y // 3) * 4) % 9 == 0 else stone
            cv.put(x, y, c if y > 74 else stone_light)
    for step in range(3):
        for x in range(66 - step * 2, 94 + step * 2):
            cv.put(x, 82 + step, stone_light if step == 0 else stone)
    red, red_dark, gold, gold_dark = (214, 62, 44), (160, 40, 34), (240, 196, 80), (196, 150, 56)
    for y in range(54, 74):
        for x in range(40, 120):
            col = (x - 40) % 10
            if y < 58:
                c = (244, 238, 222) if (x + y) % 4 else gold
                if y == 57:
                    c = gold_dark
            elif col in (0, 1):
                c = gold if col == 0 else gold_dark
            else:
                c = red if x < 80 else red_dark
                if 60 <= y <= 68 and col in (4, 5, 6) and 66 <= x < 94:
                    c = (60, 30, 28)
                elif 60 <= y <= 66 and col in (3, 4, 5, 6):
                    c = gold if (x + y) % 3 == 0 else c
            cv.put(x, y, c)
    for x in range(66, 94):
        for y in range(62, 74):
            cv.put(x, y, gold if x in (66, 93) or y == 62 else (74, 40, 34))
    roof, roof_dark, roof_light = (58, 52, 62), (36, 32, 42), (96, 88, 100)
    for i in range(14):
        y = 53 - i
        span = 46 - int(i * 2.4)
        for x in range(80 - span, 80 + span + 1):
            c = roof_light if i == 13 else roof_dark if i % 4 == 0 else roof
            if x > 80 + span * 0.55:
                c = shade(c, 0.8)
            cv.put(x, y, c)
    for x in range(32, 129):
        cv.put(x, 54, gold)
        cv.put(x, 55, gold_dark)
    for i in range(8):
        y = 40 - i
        span = 20 - i * 2
        for x in range(80 - span, 80 + span + 1):
            cv.put(x, y, gold if i in (0, 7) else roof if i % 2 else roof_dark)
    for x in range(34, 127):
        if x % 7 == 0:
            cv.put(x, 56, gold)
    for y in range(84, H):
        for x in range(W):
            r = noise(x // 2, y, 6)
            near_path = abs(x - 80) < 8 + (y - 84) * 1.6
            if near_path:
                c = (176, 170, 156) if r > 0.25 else (146, 140, 128)
                if (y - 84) % 4 == 0:
                    c = (120, 114, 104)
            else:
                c = (74, 110, 70) if r > 0.15 else (54, 90, 56)
            cv.put(x, y, c)
    for x0, h, w in ((10, 96, 7), (40, 78, 6), (150, 96, 7), (122, 80, 6)):
        sugi(cv, x0, 98, h, w)
    return cv


def tomioka():
    cv = Canvas("day")
    sky(cv, 64)
    cloud(cv, 30, 14, 7)
    cloud(cv, 128, 22, 6)
    profile(cv, lambda x: 32 + 14 * abs(math.sin(x * 0.045 + 0.5)) + 4 * math.sin(x * 0.3), 70,
            lambda x, y, d: mix((92, 124, 150), (150, 176, 196), max(0.0, 1 - d / 16) * 0.4))
    profile(cv, lambda x: 56 + 3 * math.sin(x * 0.09), 70, forest_color((60, 106, 74)))
    brick, brick_dark, mortar = (178, 82, 62), (140, 60, 48), (226, 206, 186)
    for y in range(48, 82):
        for x in range(12, 148):
            row = (y - 48) // 3
            c = mortar if (y - 48) % 3 == 2 or (x + row * 4) % 8 == 7 else brick if noise(x, y, 5) > 0.14 else brick_dark
            if y > 76 and noise(x, y, 8) > 0.3:
                c = (150, 136, 120)
            cv.put(x, y, c)
    for i in range(14):
        y = 47 - i
        span = 72 - int(i * 2.6)
        for x in range(80 - span, 80 + span + 1):
            c = (96, 100, 112) if i % 3 else (70, 74, 86)
            if i == 13:
                c = (150, 154, 164)
            cv.put(x, y, c)
    for y in range(28, 34):
        for x in range(66, 94):
            cv.put(x, y, (96, 100, 112))
    for i in range(6):
        for x in range(64 + i, 96 - i):
            cv.put(x, 28 - i, (70, 74, 86) if i < 5 else (150, 154, 164))
    for wx in range(20, 142, 13):
        if 70 <= wx <= 90:
            continue
        for y in range(56, 72):
            for x in range(wx, wx + 6):
                arch = y < 59 and (x - wx - 2.5) ** 2 + (y - 59) ** 2 > 9
                if arch:
                    continue
                cv.put(x, y, (46, 56, 70) if y > 58 else (60, 72, 90))
                if y in (56, 71) or x in (wx, wx + 5):
                    cv.put(x, y, (236, 230, 214))
    for y in range(60, 82):
        for x in range(72, 88):
            if y < 64 and (x - 79.5) ** 2 + (y - 64) ** 2 > 56:
                continue
            cv.put(x, y, (86, 54, 40) if x not in (79, 80) else (60, 38, 30))
    for y in range(8, 48):
        for x in range(150, 156):
            c = brick if x < 154 else brick_dark
            if (y - 8) % 4 == 3:
                c = mortar
            if y < 11:
                c = (60, 56, 56)
            cv.put(x, y, c)
    ground(cv, 82, (96, 140, 84))
    for y in range(86, H):
        for x in range(W):
            if abs(x - 80) < 6 + (y - 86) * 1.4:
                cv.put(x, y, (216, 196, 156) if noise(x, y, 9) > 0.2 else (196, 174, 136))
    pine(cv, 14, 96, 38)
    pine(cv, 148, 96, 40, flip=True)
    return cv


def fujisan():
    cv = Canvas("evening")
    sky(cv, 68)
    cloud(cv, 30, 16, 6)
    cloud(cv, 134, 10, 5)
    fuji(cv, 82, 8, 68, 78, 17, rock=(112, 106, 158))
    profile(cv, lambda x: 62 + 2 * math.sin(x * 0.17) if x < 60 or x > 108 else None, 68, forest_color((40, 74, 62)))
    water(cv, 68, 92, (70, 82, 130))
    for y in range(72, 92, 3):
        for x in range(40, 124):
            if noise(x // 2, y, 6) > 0.8:
                cv.put(x, y, mix(cv.get(x, y), (255, 214, 160), 0.5), tint=False)
    ground(cv, 92, (84, 120, 76))
    for x in range(W):
        for y in range(92, 95):
            cv.put(x, y, (200, 190, 150) if y == 92 else (120, 104, 84))
    pine(cv, 20, 98, 56)
    pine(cv, 142, 98, 50, flip=True)
    for bx, by, r in ((60, 92, 6), (104, 94, 7)):
        for y in range(by - r, by):
            for x in range(bx - r - 2, bx + r + 3):
                if ((x - bx) / (r + 2)) ** 2 + ((y - by) / r) ** 2 > 1 + 0.2 * noise(x, y, 6) - 0.2:
                    continue
                n = noise(x // 2, y // 2, bx)
                cv.put(x, y, (246, 176, 196) if n < 0.5 else (232, 140, 170) if n < 0.8 else (255, 214, 224))
    return cv


def gassho(cv, cx, base, w, h, lit):
    thatch, thatch_dark, thatch_light = (160, 132, 82), (112, 92, 60), (200, 176, 118)
    wall, wall_dark = (92, 66, 50), (62, 44, 36)
    for y in range(base - h // 3, base):
        for x in range(cx - w // 2 + 3, cx + w // 2 - 2):
            cv.put(x, y, wall if (x + y) % 5 else wall_dark)
    for k in range(2):
        for wx in (cx - w // 4 + k * w // 3 - 2, cx + w // 6 + k * 4):
            for y in range(base - h // 3 + 3, base - 2):
                for x in range(wx, wx + 3):
                    cv.put(x, y, (255, 220, 130) if lit else (210, 200, 170), tint=not lit)
    top = base - h
    for y in range(top, base - h // 4):
        t = (y - top) / (h * 0.75)
        half = 1 + t * (w / 2 + 4)
        for x in range(int(cx - half), int(cx + half) + 1):
            r = noise(x, y, 7)
            c = thatch_light if (y + x // 3) % 6 == 0 else thatch if r > 0.2 else thatch_dark
            if x > cx + half * 0.5:
                c = shade(c, 0.8)
            if y < top + 4 and abs(x - cx) < half - 1 and r > 0.3:
                c = (240, 244, 250)
            cv.put(x, y, c)
    for y in range(top - 1, top + 2):
        cv.put(cx, y, thatch_dark)
        cv.put(cx + 1, y, thatch_dark)


def shirakawago():
    cv = Canvas("night")
    sky(cv, 62)
    moon(cv, 132, 16)
    profile(cv, lambda x: 30 + 12 * abs(math.sin(x * 0.04 + 1)) + 3 * math.sin(x * 0.2), 70,
            lambda x, y, d: (236, 240, 250) if d < 6 else (96, 112, 138))
    profile(cv, lambda x: 54 + 3 * math.sin(x * 0.1), 74, forest_color((60, 96, 84)))
    for y in range(72, H):
        for x in range(W):
            r = noise(x, y, 3)
            c = (240, 244, 252) if y == 72 else (214, 222, 236) if r > 0.2 else (190, 202, 222)
            cv.put(x, y, c)
    gassho(cv, 46, 86, 40, 36, True)
    gassho(cv, 104, 90, 50, 42, True)
    gassho(cv, 148, 84, 30, 26, False)
    for x in range(W):
        if noise(x // 3, 0, 5) > 0.5:
            cv.put(x, 91, (160, 176, 202))
    pine(cv, 14, 98, 40, needle=(36, 72, 66))
    pine(cv, 74, 99, 30, needle=(36, 72, 66))
    for n in range(60):
        x, y = int(noise(n, 4, 8) * W), int(noise(n, 5, 8) * H)
        cv.put(x, y, (250, 252, 255), tint=False)
    return cv


def deer(cv, x, y, flip=False):
    s = -1 if flip else 1
    body, body_dark, belly, spot = (176, 120, 68), (132, 86, 48), (226, 196, 150), (246, 236, 214)
    for dx in range(0, 9):
        for dy in range(0, 4):
            c = body if dy < 2 else belly if dy == 3 else body_dark
            if dy == 1 and dx in (2, 5):
                c = spot
            cv.put(x + s * dx, y + dy, c)
    for dx in (1, 2, 6, 7):
        for dy in range(4, 8):
            cv.put(x + s * dx, y + dy, body_dark if dx in (2, 7) else body)
    for k in range(5):
        cv.put(x + s * (9 + k // 2), y - k, body)
        cv.put(x + s * (10 + k // 2), y - k, body)
    for dx in range(11, 15):
        cv.put(x + s * dx, y - 5, body)
        cv.put(x + s * dx, y - 4, body)
    cv.put(x + s * 15, y - 4, (60, 44, 40))
    cv.put(x + s * 13, y - 6, (150, 110, 70))
    cv.put(x + s * 14, y - 7, (200, 190, 160))
    cv.put(x + s * 12, y - 7, (200, 190, 160))
    cv.put(x - s, y + 1, spot)


def nara():
    cv = Canvas("morning")
    sky(cv, 66)
    cloud(cv, 40, 14, 7)
    cloud(cv, 142, 22, 5)
    profile(cv, lambda x: 40 + 14 * math.sin(x * 0.02 + 2.4) + 2 * math.sin(x * 0.17), 80,
            forest_color((70, 112, 84), False))
    for x in range(-2, W + 4, 12):
        sugi(cv, x, 84, 22 + int(noise(x, 2, 3) * 10), 3)
    stone, stone_dark = (176, 170, 156), (130, 124, 112)
    for y in range(76, 84):
        for x in range(64, 124):
            cv.put(x, y, stone_dark if (y - 76) % 3 == 0 or (x + y) % 8 == 0 else stone)
    red, red_dark, roof, roof_dark, roof_light, gold = (216, 76, 52), (160, 50, 40), (70, 66, 72), (44, 42, 50), (120, 116, 122), (240, 200, 90)
    cx, y = 94, 76
    for tier, (w, h) in enumerate(((17, 8), (15, 7), (13, 7), (11, 6), (9, 6))):
        for yy in range(y - h, y):
            for x in range(cx - w + 2, cx + w - 1):
                c = red if x < cx + w // 3 else red_dark
                if (x - cx) % 5 == 0 or (yy == y - h and tier):
                    c = gold if (x - cx) % 5 == 0 else red_dark
                if tier == 0 and abs(x - cx) < 3 and yy > y - 5:
                    c = (60, 34, 30)
                cv.put(x, yy, c)
        y -= h
        for i in range(3):
            span = w + 4 - i * 2
            for x in range(cx - span, cx + span + 1):
                c = roof_light if i == 2 else roof if i == 1 else roof_dark
                cv.put(x, y - i, shade(c, 0.85) if x > cx + span * 0.5 else c)
        cv.put(cx - w - 5, y - 2, roof_light)
        cv.put(cx + w + 5, y - 2, roof_light)
        y -= 2
    for yy in range(y - 12, y):
        cv.put(cx, yy, gold)
        if (y - yy) % 3 == 0:
            cv.put(cx - 1, yy, gold)
            cv.put(cx + 1, yy, gold)
    ground(cv, 84, (110, 164, 90))
    for y in range(84, H):
        for x in range(W):
            if abs(x - 94) < 5 + (y - 84) * 0.7 and noise(x, y, 5) > 0.15:
                cv.put(x, y, (200, 190, 168) if noise(x, y, 9) > 0.3 else (176, 166, 144))
    deer(cv, 20, 90)
    deer(cv, 44, 96, True)
    deer(cv, 128, 88)
    deer(cv, 144, 95, True)
    lantern, lantern_dark = (170, 166, 154), (120, 116, 106)
    for lx in (56, 134):
        for y in range(80, 90):
            cv.put(lx, y, lantern if y > 82 else lantern_dark)
            cv.put(lx + 1, y, lantern_dark)
        for x in range(lx - 3, lx + 5):
            cv.put(x, 79, lantern)
            cv.put(x, 78, lantern_dark)
        cv.put(lx, 81, (255, 220, 140), tint=False)
    return cv


def himeji():
    cv = Canvas("day")
    sky(cv, 70)
    cloud(cv, 30, 16, 7)
    cloud(cv, 140, 12, 5)
    profile(cv, lambda x: 56 + 5 * math.sin(x * 0.04 + 1), 78, forest_color((84, 124, 110), False))
    stone, stone_dark, stone_light = (160, 154, 140), (118, 112, 100), (192, 186, 170)
    wall, wall_shade = (250, 248, 242), (214, 214, 214)
    roof, roof_dark, roof_light = (96, 100, 110), (62, 66, 76), (150, 154, 164)
    cx, base = 80, 84
    castle = {}
    for y in range(base - 14, base):
        t = (y - (base - 14)) / 14
        hw = 36 + 10 * t ** 2.2
        for x in range(int(cx - hw), int(cx + hw) + 1):
            row = (y - base) // 3
            c = stone_dark if (y - base) % 3 == 0 or (x + row * 3) % 7 == 0 else stone_light if noise(x, y, 2) > 0.85 else stone
            if x > cx + hw * 0.5:
                c = shade(c, 0.85)
            castle[(x, y)] = c
    y = base - 14
    for tier, (w, h) in enumerate(((46, 7), (38, 6), (30, 6), (22, 6), (14, 6))):
        half = w // 2
        for yy in range(y - h, y):
            for x in range(cx - half, cx + half + 1):
                castle[(x, yy)] = wall_shade if x > cx + half * 0.5 else wall
        for k in range(-half + 4, half - 3, 6):
            for dy in (0, 1):
                for dx in (0, 1):
                    castle[(cx + k + dx, y - h + 2 + dy)] = (60, 56, 60)
        y -= h
        eave = half + 4
        for i in range(3):
            span = eave - i * 2
            for x in range(cx - span, cx + span + 1):
                c = roof_light if i == 2 else roof if i == 1 else roof_dark
                castle[(x, y - i)] = shade(c, 0.85) if x > cx + span * 0.5 else c
        if tier in (1, 2, 3):
            for i in range(5):
                for x in range(cx - 7 + i, cx + 8 - i):
                    castle[(x, y - 3 - i)] = wall if i < 4 else roof_light
            for x in range(cx - 8, cx + 9):
                castle[(x, y - 3)] = roof_dark
            y -= 2
        y -= 3
    for x in range(cx - 8, cx + 9):
        castle[(x, y)] = roof_dark
    castle[(cx - 9, y - 1)] = (240, 196, 70)
    castle[(cx + 9, y - 1)] = (240, 196, 70)
    for side, (sw, sh) in ((-1, (14, 12)), (1, (12, 10))):
        sx = cx + side * 42
        for yy in range(base - 14 - sh, base - 14):
            for x in range(sx - sw // 2, sx + sw // 2 + 1):
                castle[(x, yy)] = wall_shade if x > sx else wall
        for i in range(4):
            for x in range(sx - sw // 2 - 3 + i, sx + sw // 2 + 4 - i):
                castle[(x, base - 14 - sh - i)] = roof if i < 3 else roof_light
    draw(cv, castle)
    ground(cv, 84, (104, 154, 88))
    for y in range(86, H):
        for x in range(W):
            if abs(x - 80) < 7 + (y - 86) * 1.2:
                cv.put(x, y, (220, 206, 176) if noise(x, y, 9) > 0.2 else (196, 182, 152))
    for bx, by, r in ((20, 82, 13), (140, 84, 14), (52, 90, 8), (110, 92, 8)):
        for y in range(by - r, by + 1):
            for x in range(bx - r - 2, bx + r + 3):
                if ((x - bx) / (r + 2)) ** 2 + ((y - by) / r) ** 2 > 1 + 0.2 * noise(x, y, 6) - 0.12:
                    continue
                n = noise(x // 2, y // 2, bx)
                cv.put(x, y, (248, 196, 212) if n < 0.5 else (236, 160, 186) if n < 0.8 else (255, 226, 232))
        for y in range(by, by + 8):
            cv.put(bx, y, (96, 66, 52))
    return cv


def itsukushima():
    cv = Canvas("evening")
    sky(cv, 64)
    cloud(cv, 26, 14, 6)
    cloud(cv, 134, 22, 6)
    disc(cv, 100, 52, 5, (255, 214, 140), glow=(255, 190, 120))
    profile(cv, lambda x: 24 + (x - 20) ** 2 * 0.012 if x < 62 else None, 64, forest_color((50, 80, 76)), 0, 62)
    profile(cv, lambda x: 42 + 4 * math.sin(x * 0.13) if x > 110 else None, 64, forest_color((58, 84, 80)), 110, W)
    water(cv, 64, H, (70, 84, 124))
    for y in range(66, 94, 2):
        half = 4 + (y - 64) * 0.3
        start = int(100 - half + noise(y, 0, 2) * 3)
        length = int(half * (0.8 + noise(y, 1, 2) * 0.8))
        for x in range(start, start + length):
            cv.put(x, y, mix(cv.get(x, y), (255, 206, 140), 0.6), tint=False)
    red, red_dark, roof = (222, 70, 50), (160, 46, 40), (70, 60, 64)
    hall = {}
    for y in range(52, 66):
        for x in range(112, 160):
            col = (x - 112) % 8
            hall[(x, y)] = (240, 236, 220) if y < 56 else red if col not in (0, 1) else red_dark
    for i in range(4):
        for x in range(108 + i, 160):
            hall[(x, 52 - i)] = roof if i < 3 else (110, 100, 104)
    for x in range(112, 160, 8):
        for y in range(66, 74):
            hall[(x, y)] = red_dark
    draw(cv, {k: v for k, v in hall.items() if k[1] <= 64})
    reflect(cv, {k: v for k, v in hall.items() if k[1] <= 64}, 64, 64, H, (70, 84, 124), 0.5)
    draw(cv, {k: v for k, v in hall.items() if k[1] > 64})
    gate = torii(76, 22, 82, 22, red=(228, 72, 52))
    draw(cv, {k: v for k, v in gate.items() if k[1] <= 64})
    reflect(cv, {k: v for k, v in gate.items() if k[1] <= 64}, 82, 64, H, (70, 84, 124), 0.5)
    draw(cv, {k: v for k, v in gate.items() if k[1] > 64})
    for x in range(W):
        for y in range(96, H):
            if noise(x, y, 8) > 0.9:
                cv.put(x, y, (255, 226, 170), tint=False)
    return cv


SCENES = {
    "nikko": nikko,
    "tomioka": tomioka,
    "fujisan": fujisan,
    "shirakawago": shirakawago,
    "nara": nara,
    "himejijo": himeji,
    "itsukushima": itsukushima,
}
