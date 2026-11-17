import math
from artlib.landmark_kit import Canvas, H, SKIES, W, cloud, disc, draw, forest_color, fuji, ground, mix, moon, noise, pine, profile, reflect, shade, sky, torii, water


def nihonbashi():
    cv = Canvas("morning")
    sky(cv, 66)
    cloud(cv, 120, 14, 7)
    x = 0
    i = 0
    while x < W:
        bw = 10 + int(noise(i, 0, 9) * 10)
        bh = 12 + int(noise(i, 1, 9) * 12)
        top = 62 - bh
        brick = noise(i, 2, 9) > 0.62
        wall = (176, 96, 74) if brick else (238, 232, 220)
        for yy in range(top, 64):
            for xx in range(x, min(W, x + bw)):
                c = wall
                if yy < top + 3:
                    c = (60, 64, 72) if not brick else (110, 66, 56)
                elif not brick and yy > top + 3 and (yy - top) % 6 == 4 and (xx - x) % 4 in (1, 2):
                    c = (70, 66, 64)
                elif brick and (yy - top) % 5 == 3 and (xx - x) % 4 in (1, 2):
                    c = (230, 210, 150)
                elif xx == x + bw - 1:
                    c = shade(wall, 0.8)
                cv.put(xx, yy, c)
        if not brick:
            for k in range(4):
                for xx in range(x - 1 + k, x + bw + 1 - k):
                    cv.put(xx, top - k, (52, 56, 64) if k < 3 else (90, 96, 104))
        x += bw + 1
        i += 1
    water(cv, 66, H, (60, 108, 104))

    bridge = {}
    stone, stone_dark, stone_light = (182, 178, 166), (140, 136, 126), (210, 206, 194)
    for y in range(50, 80):
        for x in range(4, 156):
            hole = any(((x - cx) / 23) ** 2 + ((y - 70) / 15) ** 2 < 1 for cx in (46, 114))
            if hole:
                bridge[(x, y)] = (30, 48, 50) if (x + y) % 5 else (40, 62, 62)
                continue
            c = stone
            if (y - 50) % 4 == 0 or (x + ((y - 50) // 4) * 3) % 8 == 0:
                c = stone_dark
            elif noise(x, y, 4) > 0.9:
                c = stone_light
            bridge[(x, y)] = c
    for x in range(4, 156):
        bridge[(x, 50)] = stone_light
        bridge[(x, 46)] = stone_light
        bridge[(x, 47)] = stone
        if x % 6 == 0:
            for y in (48, 49):
                bridge[(x, y)] = stone
    draw(cv, {k: v for k, v in bridge.items() if k[1] <= 66})
    reflect(cv, {k: v for k, v in bridge.items() if k[1] <= 66}, 66, 66, H, (60, 108, 104), 0.7)
    draw(cv, {k: v for k, v in bridge.items() if 66 < k[1] < 72})
    bronze, bronze_dark, lamp = (64, 104, 92), (40, 70, 62), (255, 236, 170)
    for lx, top in ((24, 32), (80, 22), (136, 32)):
        big = lx == 80
        for y in range(top, 46):
            width = 2 if not big or y < 38 else 4
            for k in range(width):
                cv.put(lx - width // 2 + 1 + k, y, bronze if k < width - 1 else bronze_dark)
        if big:
            for y in range(40, 46):
                for x in range(75, 87):
                    cv.put(x, y, (176, 172, 160) if x < 84 else (140, 136, 126))
            for x in range(73, 89):
                cv.put(x, 40, (210, 206, 194))
        globes = ((-4, 0), (4, 0), (0, -4), (-2, -2), (2, -2)) if big else ((-3, 0), (3, 0), (0, -3))
        for dx, dy in globes:
            for k in range(2):
                for j in range(2):
                    cv.put(lx + dx + k, top + dy + j, lamp, tint=False)
        for x in range(lx - (5 if big else 3), lx + (7 if big else 5)):
            cv.put(x, top + 3, bronze_dark)
    return cv


def ashinoko():
    cv = Canvas("day")
    sky(cv, 60)
    cloud(cv, 42, 12, 7)
    cloud(cv, 140, 18, 5)
    fuji(cv, 96, 24, 52, 28, 8, rock=(120, 142, 178), haze=0.25)
    profile(cv, lambda x: 20 + (x - 28) ** 2 * 0.018 if x < 86 else None, 62, forest_color((52, 98, 70)), 0, 86)
    profile(cv, lambda x: 30 + (x - 142) ** 2 * 0.03 if x > 112 else None, 62, forest_color((58, 104, 74)), 112, W)
    profile(cv, lambda x: 50 - 2 * math.sin(x * 0.2), 62, forest_color((44, 86, 62)), 70, 125)
    water(cv, 60, 92, (40, 96, 92))
    gate = torii(134, 46, 70, 9)
    draw(cv, {k: v for k, v in gate.items() if k[1] <= 60})
    reflect(cv, {k: v for k, v in gate.items() if k[1] <= 60}, 70, 60, 92, (40, 96, 92))
    draw(cv, {k: v for k, v in gate.items() if k[1] > 60})
    hull, gold, sail = (110, 56, 36), (230, 186, 80), (248, 246, 236)
    ship = {}
    for y in range(64, 70):
        inset = (y - 64) // 2
        for x in range(46 + inset, 76 - inset):
            ship[(x, y)] = gold if y == 65 else hull
    for x in range(72, 79):
        ship[(x, 63)] = hull
    for mx, mh in ((52, 16), (61, 19), (70, 14)):
        for y in range(64 - mh, 64):
            ship[(mx, y)] = (80, 56, 40)
        for y in range(64 - mh + 3, 62):
            span = 2 + (y - (64 - mh + 3)) // 3
            for x in range(mx - span, mx + span + 1):
                ship[(x, y)] = sail if x <= mx else shade(sail, 0.88)
        ship[(mx + 1, 64 - mh)] = (214, 62, 46)
        ship[(mx + 2, 64 - mh)] = (214, 62, 46)
    draw(cv, ship)
    reflect(cv, ship, 69, 69, 92, (40, 96, 92), 0.4)
    ground(cv, 92, (84, 130, 80))
    pine(cv, 10, 94, 40)
    return cv


def miho():
    cv = Canvas("day")
    sky(cv, 58)
    cloud(cv, 30, 10, 6)
    cloud(cv, 150, 30, 5)
    profile(cv, lambda x: 54 - 3 * math.sin(x * 0.08) if x < 40 else None, 58, forest_color((110, 140, 150), False), 0, 40)
    fuji(cv, 104, 10, 58, 74, 15)
    sea = (36, 94, 160)
    water(cv, 58, 80, sea)
    for y in range(60, 80, 4):
        for x in range(W):
            if noise(x // 3, y, 8) > 0.86:
                cv.put(x, y, (240, 246, 250))
    for x in range(W):
        top = 79 + int(2 * math.sin(x * 0.18) + 1.5 * math.sin(x * 0.07 + 1))
        for y in range(top, top + 3):
            cv.put(x, y, (250, 252, 252) if noise(x, y, 1) > 0.25 else (200, 224, 236))
        for y in range(top + 3, top + 6):
            cv.put(x, y, (196, 180, 150))
    for y in range(84, H):
        for x in range(W):
            if cv.get(x, y) == cv.tint((196, 180, 150)) and y < 86:
                continue
            r = noise(x, y, 6)
            cv.put(x, y, (226, 210, 176) if r < 0.15 else (240, 228, 198) if r > 0.85 else (234, 220, 188))
    trunk, trunk_dark = (104, 76, 60), (72, 52, 42)
    for i in range(70):
        t = i / 70
        x = 22 + 22 * t + 6 * math.sin(t * 5)
        y = 100 - 62 * t
        width = int(4 - 2.5 * t)
        for k in range(width + 1):
            cv.put(int(x) + k, int(y), trunk if k < width else trunk_dark)
    for bx, by, length, rise in ((40, 52, 26, -0.25), (30, 64, 18, -0.15), (44, 42, 20, -0.35)):
        for i in range(length):
            cv.put(bx + i, by + int(i * rise), trunk)
    for px, py, w, h in ((66, 44, 13, 4), (58, 58, 10, 3), (64, 34, 11, 4), (30, 60, 9, 3), (46, 36, 10, 3), (24, 50, 7, 3)):
        for y in range(py - h, py + 1):
            for x in range(px - w, px + w + 1):
                dx, dy = (x - px) / w, (py - y) / h
                if dx * dx + dy * dy * 1.3 <= 1 + 0.12 * math.sin(x * 1.9) and dy >= 0:
                    c = (44, 92, 70)
                    if dy > 0.7 or (dy > 0.45 and (x + y) % 3 == 0):
                        c = (98, 146, 104)
                    elif dy < 0.2:
                        c = (30, 64, 50)
                    cv.put(x, y, c)
    return cv


def hamanako():
    cv = Canvas("evening")
    sky(cv, 60)
    cloud(cv, 120, 16, 6)
    disc(cv, 48, 54, 6, (255, 214, 140), glow=(255, 190, 120))
    profile(cv, lambda x: 56 - 2 * math.sin(x * 0.05), 60, lambda x, y, d: (92, 70, 104))
    for x in range(W):
        cv.put(x, 53, (70, 56, 84))
        if x % 12 < 2:
            for y in range(54, 60):
                cv.put(x, y, (70, 56, 84))
    for x in range(W):
        if x % 24 < 12:
            arch = int(2 * math.sin((x % 24) / 12 * math.pi))
            cv.put(x, 52 - arch, (70, 56, 84))
    water(cv, 60, 92, (70, 82, 120))
    for y in range(62, 92, 2):
        half = 3 + (y - 60) * 0.25
        start = int(48 - half + noise(y, 0, 2) * 3)
        length = int(half * (0.8 + noise(y, 1, 2) * 0.8))
        for x in range(start, start + length):
            cv.put(x, y, mix(cv.get(x, y), (255, 206, 140), 0.65), tint=False)
    gate = torii(110, 34, 76, 15, red=(222, 70, 50))
    draw(cv, {k: v for k, v in gate.items() if k[1] <= 60})
    reflect(cv, {k: v for k, v in gate.items() if k[1] <= 60}, 76, 60, 92, (70, 82, 120))
    draw(cv, {k: v for k, v in gate.items() if k[1] > 60})
    for row, (y0, step, h) in enumerate(((68, 6, 5), (75, 8, 7), (84, 11, 9))):
        for x in range(60 + row * 3, W, step):
            if 90 < x < 132:
                continue
            for y in range(y0 - h, y0 + 1):
                cv.put(x, y, (176, 150, 104) if y > y0 - h else (210, 186, 130))
            for y in range(y0 + 1, y0 + 1 + h // 2):
                if y % 2:
                    cv.put(x, y, (120, 104, 96))
    for y in range(92, H):
        for x in range(W):
            cv.put(x, y, (170, 164, 156) if y == 92 else (140, 134, 128) if noise(x, y, 4) > 0.2 else (120, 114, 110))
    return cv


def nagoya():
    cv = Canvas("evening")
    sky(cv, 80)
    cloud(cv, 30, 18, 6)
    cloud(cv, 136, 12, 5)
    profile(cv, lambda x: 72 - 3 * math.sin(x * 0.06 + 2), 80, lambda x, y, d: (120, 126, 150))
    profile(cv, lambda x: 76 - 3 * abs(math.sin(x * 0.45)), 80, forest_color((68, 110, 80)))
    stone, stone_dark, stone_light = (158, 150, 134), (116, 108, 96), (190, 182, 166)
    wall, wall_shade = (242, 238, 228), (208, 204, 198)
    roof, roof_dark, roof_light = (84, 150, 138), (52, 102, 98), (140, 198, 180)
    gold, window, lit = (240, 196, 70), (60, 52, 50), (255, 214, 120)
    cx, base = 86, 82
    castle = {}
    for y in range(base - 18, base):
        t = (y - (base - 18)) / 18
        hw = 24 + 10 * t ** 2.6
        for x in range(int(cx - hw), int(cx + hw) + 1):
            row = (y - base) // 3
            c = stone_dark if (y - base) % 3 == 0 or (x + row * 3) % 7 == 0 else stone_light if noise(x, y, 2) > 0.85 else stone
            if x > cx + hw * 0.5:
                c = shade(c, 0.85)
            castle[(x, y)] = c
    y = base - 18
    for tier, (w, h) in enumerate(((42, 7), (36, 6), (30, 6), (24, 5), (17, 6))):
        half = w // 2
        for yy in range(y - h, y):
            for x in range(cx - half, cx + half + 1):
                castle[(x, yy)] = wall_shade if x > cx + half * 0.45 else wall
        for k in range(-half + 3, half - 2, 5):
            for dx in (0, 1):
                for dy in (0, 1):
                    castle[(cx + k + dx, y - h + 2 + dy)] = lit if (k + tier) % 3 else window
        y -= h
        eave = half + 4
        for i in range(3):
            span = eave - i * 2
            for x in range(cx - span, cx + span + 1):
                c = roof_light if i == 2 else roof if i == 1 else roof_dark
                castle[(x, y - i)] = shade(c, 0.8) if x > cx + span * 0.5 else c
        castle[(cx - eave - 1, y - 1)] = roof_light
        castle[(cx + eave + 1, y - 1)] = roof_light
        if tier in (1, 3):
            for i in range(4):
                for x in range(cx - 4 + i, cx + 5 - i):
                    castle[(x, y - 3 - i)] = roof if i < 3 else roof_light
        y -= 3
    for x in range(cx - 11, cx + 12):
        castle[(x, y)] = roof_dark
    for side in (-10, 9):
        for dx, dy in ((0, -1), (1, -1), (0, -2), (1, -3), (0, -3)):
            castle[(cx + side + dx, y + dy)] = gold
    draw(cv, castle)
    water(cv, 82, 92, (58, 84, 96))
    reflect(cv, castle, 82, 82, 92, (58, 84, 96), 0.6)
    for y in range(92, H):
        for x in range(W):
            r = noise(x // 3, y // 2, 7)
            cv.put(x, y, (170, 162, 146) if y == 92 else (140, 132, 118) if r > 0.3 else (118, 110, 98))
    pine(cv, 14, 92, 34)
    pine(cv, 146, 92, 38, flip=True)
    return cv


def biwako():
    cv = Canvas("morning")
    sky(cv, 58)
    cloud(cv, 120, 14, 6)
    profile(cv, lambda x: 30 + (x - 30) ** 2 * 0.012 if x < 95 else None, 58,
            lambda x, y, d: mix((92, 116, 150), SKIES["morning"][-1], max(0.0, (y - 40) / 18) * 0.6), 0, 95)
    for x in range(95, W):
        cv.put(x, 56, (150, 160, 180))
        cv.put(x, 57, (160, 168, 186))
    water(cv, 58, 94, (110, 150, 180))
    for y in range(58, 66):
        for x in range(W):
            if noise(x, y, 1) > 0.5:
                cv.put(x, y, mix(cv.get(x, y), (250, 240, 236), 0.35), tint=False)
    gate = torii(52, 40, 70, 10)
    draw(cv, {k: v for k, v in gate.items() if k[1] <= 58})
    reflect(cv, {k: v for k, v in gate.items() if k[1] <= 58}, 70, 58, 94, (110, 150, 180))
    draw(cv, {k: v for k, v in gate.items() if k[1] > 58})
    boat = {}
    for y in range(44, 58):
        span = (y - 44) // 2
        for x in range(124 - span, 125):
            boat[(x, y)] = (250, 248, 240)
        for x in range(125, 126 + span // 2):
            boat[(x, y)] = (226, 224, 220)
    for x in range(116, 134):
        boat[(x, 58)] = (90, 66, 52)
        if 117 < x < 133:
            boat[(x, 59)] = (70, 52, 42)
    draw(cv, boat)
    reflect(cv, boat, 59, 59, 94, (110, 150, 180), 0.35)
    for y in range(94, H):
        for x in range(W):
            cv.put(x, y, (150, 140, 120) if noise(x, y, 3) > 0.3 else (120, 112, 98))
    for x in range(0, 70, 2):
        h = 10 + int(noise(x, 0, 5) * 12)
        lean = 1 if noise(x, 1, 5) > 0.5 else 0
        for i in range(h):
            cv.put(x + (lean if i > h * 0.6 else 0), 99 - i, (170, 160, 104) if i > h - 4 else (110, 120, 70))
    return cv


def kiyomizu():
    cv = Canvas("night")
    sky(cv, 70)
    moon(cv, 24, 14)
    profile(cv, lambda x: 34 + 10 * math.sin(x * 0.02 + 0.4) + 3 * math.sin(x * 0.11), H, lambda x, y, d: (40, 52, 60))
    wood, wood_dark, wood_light = (150, 104, 66), (104, 70, 44), (196, 146, 96)
    glow = lambda c: mix(c, (255, 190, 110), 0.3)
    for y in range(52, 86):
        for x in range(18, 92):
            pillar = (x - 18) % 6 in (0, 1)
            beam = (y - 52) % 7 == 0
            if pillar or beam:
                c = wood_dark if (x - 18) % 6 == 1 else wood
                if beam:
                    c = wood_light
                cv.put(x, y, glow(c), tint=False)
    for x in range(10, 96):
        for y in range(49, 53):
            cv.put(x, y, glow(wood_light if y == 49 else wood), tint=False)
        if x % 4 == 0:
            for y in range(45, 49):
                cv.put(x, y, glow(wood), tint=False)
        cv.put(x, 45, glow(wood_light), tint=False)
    for y in range(36, 49):
        for x in range(34, 96):
            c = (226, 92, 56) if (x - 34) % 8 in (0, 1) else (90, 60, 46)
            cv.put(x, y, glow(c), tint=False)
    for i in range(16):
        y = 36 - i
        curve = int(3 * (1 - math.cos(i / 15 * math.pi / 2)) * 2)
        x0, x1 = 26 + i + (0 if i > 2 else -curve), 104 - i
        for x in range(x0, x1):
            c = (74, 58, 54) if i % 3 else (96, 78, 72)
            cv.put(x, y, c, tint=False)
    for x in range(52, 79):
        cv.put(x, 20, (110, 92, 84), tint=False)
    pagoda_red = (232, 86, 58)
    pcx = 134
    y = 66
    for tier in range(3):
        w = 9 - tier * 2
        for yy in range(y - 6, y):
            for x in range(pcx - w + 2, pcx + w - 1):
                cv.put(x, yy, glow(pagoda_red if (x + yy) % 5 else (180, 60, 44)), tint=False)
        y -= 6
        for i in range(3):
            for x in range(pcx - w - 3 + i, pcx + w + 3 - i):
                cv.put(x, y - i, (70, 56, 52) if i < 2 else (110, 92, 84), tint=False)
        y -= 3
    for yy in range(y - 10, y):
        cv.put(pcx, yy, (230, 196, 90), tint=False)
        if (yy - y) % 2 == 0:
            cv.put(pcx - 1, yy, (200, 168, 70), tint=False)
            cv.put(pcx + 1, yy, (200, 168, 70), tint=False)
    maples = [(8, 82, 10), (30, 90, 12), (60, 92, 13), (96, 84, 11), (112, 92, 10), (150, 74, 9), (126, 78, 8)]
    for mx, my, r in maples:
        for yy in range(my - r, my + r):
            for x in range(mx - r - 2, mx + r + 3):
                if ((x - mx) / (r + 2)) ** 2 + ((yy - my) / r) ** 2 > 1 + 0.25 * noise(x, yy, 6) - 0.12:
                    continue
                n = noise(x // 2, yy // 2, mx)
                c = (236, 92, 50) if n < 0.45 else (250, 150, 60) if n < 0.75 else (196, 50, 40)
                if yy < my - r * 0.4 and n > 0.6:
                    c = (255, 196, 96)
                cv.put(x, yy, c, tint=False)
    for x in range(118, W):
        for y in range(88, H):
            if noise(x, y, 12) > 0.9:
                cv.put(x, y, (255, 226, 150), tint=False)
    return cv


SCENES = {
    "nihonbashi": nihonbashi,
    "ashinoko": ashinoko,
    "miho": miho,
    "hamanako": hamanako,
    "nagoyajo": nagoya,
    "biwako": biwako,
    "kiyomizu": kiyomizu,
}
