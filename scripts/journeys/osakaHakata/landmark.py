import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, draw, forest_color, ground, mix, noise, pine, profile, reflect, shade, sky, water


def facade(layer, x0, x1, top, base, wall, lit, seed):
    dark = shade(wall, 0.78)
    for y in range(top, base):
        for x in range(x0, x1):
            c = wall if x < x1 - 2 else dark
            if (y - top) % 6 in (2, 3) and (x - x0) % 5 in (1, 2) and x1 - x > 3 and y > top + 3:
                c = lit if noise(x // 5, y // 6, seed) > 0.3 else shade(wall, 0.6)
            layer[(x, y)] = c
    for x in range(x0 - 1, x1 + 1):
        layer[(x, top - 1)] = shade(wall, 1.25)


def board(layer, x0, y0, w, h, face, stripe, seed):
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            edge = x in (x0, x0 + w - 1) or y in (y0, y0 + h - 1)
            c = (250, 244, 220) if edge else face
            if not edge and (x - x0 + (y - y0) // 3 * 2) % 7 in (3, 4) and noise(x, y // 3, seed) > 0.35:
                c = stripe
            layer[(x, y)] = c


def dotonbori():
    cv = Canvas("night")
    sky(cv, 40)
    glow = {}
    for x0, x1, top, wall in ((-4, 12, 18, (70, 60, 90)), (12, 30, 30, (62, 66, 96)), (30, 48, 14, (92, 58, 70)),
                              (48, 64, 34, (58, 74, 96)), (64, 96, 48, (60, 64, 92)), (96, 112, 24, (84, 64, 90)), (112, 134, 36, (66, 70, 100)),
                              (134, 150, 16, (78, 60, 80)), (150, 166, 28, (62, 66, 96))):
        facade(glow, x0, x1, top, 64, wall, (255, 214, 120), x0)
    draw(cv, glow, tint=False)
    signs = {}
    board(signs, 14, 40, 14, 12, (226, 70, 60), (255, 220, 120), 1)
    board(signs, 33, 22, 12, 20, (40, 120, 200), (255, 255, 255), 2)
    board(signs, 36, 48, 10, 8, (250, 200, 60), (210, 80, 50), 3)
    board(signs, 98, 34, 12, 16, (244, 120, 170), (255, 240, 200), 4)
    board(signs, 114, 46, 16, 10, (60, 180, 120), (255, 255, 255), 5)
    board(signs, 136, 24, 10, 22, (232, 90, 50), (255, 230, 150), 6)
    board(signs, 152, 40, 10, 12, (140, 90, 210), (255, 220, 255), 7)
    draw(cv, signs, tint=False)
    for sx in range(14, 160, 4):
        if noise(sx, 3, 4) > 0.6:
            cv.put(sx, 12 + int(noise(sx, 9, 3) * 8), (255, 240, 200), tint=False)
    ring = {}
    cx, cy, r = 78, 30, 16
    for k in range(32):
        a = k / 32 * math.tau
        ring[(int(cx + math.cos(a) * r), int(cy + math.sin(a) * r))] = (255, 230, 140) if k % 2 else (255, 120, 90)
    for k in range(8):
        a = k / 8 * math.tau
        for i in range(1, r):
            ring[(int(cx + math.cos(a) * i), int(cy + math.sin(a) * i))] = (200, 190, 220)
    for dx, dy in ((-1, -1), (0, -1), (-1, 0), (0, 0)):
        ring[(cx + dx, cy + dy)] = (255, 240, 200)
    draw(cv, {k: v for k, v in ring.items() if k[1] < 62}, tint=False)
    water(cv, 64, H, (24, 30, 70))
    for y in range(64, H, 3):
        for x in range(W):
            if noise(x // 2, y, 9) > 0.93:
                cv.put(x, y, (255, 214, 140), tint=False)
    stone, stone_dark = (112, 108, 124), (74, 72, 90)
    for y in range(76, 82):
        for x in range(0, W):
            arch = ((x - 80) / 46) ** 2 + ((y - 82) / 8) ** 2 < 1
            if arch:
                continue
            cv.put(x, y, stone_dark if (y - 76) % 3 == 0 or (x + y) % 7 == 0 else stone)
    for x in range(0, W):
        cv.put(x, 74, (176, 170, 190))
        cv.put(x, 75, stone_dark)
        if x % 6 == 0:
            for y in range(70, 74):
                cv.put(x, y, (150, 146, 170))
    for lx in (14, 52, 108, 146):
        for y in range(52, 75):
            cv.put(lx, y, (44, 40, 56))
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                if abs(dx) + abs(dy) <= 3:
                    cv.put(lx + dx, 50 + dy, (255, 232, 150), tint=False)
    for y in range(82, H):
        for x in range(W):
            if y > 84 and noise(x, y, 4) > 0.5:
                cv.put(x, y, (56, 60, 96))
    for k, x in enumerate(range(6, 160, 17)):
        for y in range(88, 96):
            cv.put(x, y, (232, 70, 60) if k % 2 else (255, 214, 120), tint=False)
            cv.put(x + 1, y, (170, 40, 40) if k % 2 else (210, 160, 70), tint=False)
        cv.put(x, 86, (44, 40, 56))
        cv.put(x, 87, (44, 40, 56))
    return cv


def nankinmachi():
    cv = Canvas("day")
    sky(cv, 56)
    cloud(cv, 24, 12, 6)
    cloud(cv, 134, 20, 5)
    profile(cv, lambda x: 38 + 8 * math.sin(x * 0.04 + 0.6) + 2 * math.sin(x * 0.2), 62, forest_color((86, 124, 112), False))
    stone, stone_dark = (200, 192, 176), (150, 142, 128)
    for y in range(60, H):
        for x in range(W):
            row = (y - 60) // 4
            joint = (y - 60) % 4 == 0 or (x + row * 5) % 10 == 0
            cv.put(x, y, stone_dark if joint else stone if noise(x // 3, row, 2) > 0.2 else (190, 182, 166))
    for x0, x1, top, wall in ((0, 36, 36, (232, 204, 150)), (36, 50, 44, (206, 120, 90)),
                              (110, 124, 44, (206, 120, 90)), (124, 160, 32, (232, 204, 150))):
        for y in range(top, 66):
            for x in range(x0, x1):
                c = wall if x < x1 - 3 else shade(wall, 0.82)
                if (y - top) % 8 in (3, 4) and (x - x0) % 8 in (2, 3, 4) and y > top + 3:
                    c = (80, 60, 52)
                cv.put(x, y, c)
        for i in range(4):
            for x in range(x0 - 2 + i, x1 + 2 - i):
                cv.put(x, top - i, (170, 52, 44) if i < 3 else (214, 100, 70))
    red, red_dark, gold, gold_dark, jade, jade_dark = (210, 54, 44), (154, 36, 34), (244, 200, 80), (196, 150, 56), (62, 150, 120), (36, 104, 84)
    for px in (50, 100):
        for y in range(30, 84):
            for k in range(6):
                cv.put(px + k, y, red if k < 4 else red_dark)
            if y % 12 == 0:
                for k in range(-1, 7):
                    cv.put(px + k, y, gold)
        for k in range(-2, 8):
            cv.put(px + k, 84, (150, 142, 130))
            cv.put(px + k, 85, (110, 104, 96))
    for tier, (y, half) in enumerate(((22, 46), (36, 40))):
        for x in range(75 - half, 75 + half + 1):
            lift = int(abs(x - 75) > half - 6) * 2 + int(abs(x - 75) > half - 3)
            for k in range(5):
                c = jade if k < 3 else jade_dark
                if k == 0:
                    c = mix(jade, (255, 255, 255), 0.35)
                cv.put(x, y + k - lift, c)
            if (x - 75) % 4 == 0:
                cv.put(x, y + 5 - lift, gold)
    for y in range(37, 48):
        for x in range(50, 106):
            c = red if x < 78 else red_dark
            if y in (37, 47):
                c = gold
            elif 40 <= y <= 44 and 58 <= x <= 92 and (x - 58) % 6 in (1, 2, 3, 4):
                c = gold if (x + y) % 2 else gold_dark
            cv.put(x, y, c)
    for x in range(65, 86):
        for y in range(12, 22):
            cv.put(x, y, jade if y < 18 else jade_dark)
    for i in range(5):
        for x in range(64 + i, 87 - i):
            cv.put(x, 11 - i, mix(jade, (255, 255, 255), 0.3) if i == 4 else jade)
    cv.put(75, 4, gold)
    cv.put(75, 5, gold)
    cv.put(74, 6, gold_dark)
    cv.put(76, 6, gold_dark)
    for y in range(48, 84):
        for x in range(56, 100):
            if x < 58 or x > 97:
                continue
            cv.put(x, y, (232, 214, 170) if (x // 5 + y // 5) % 2 else (216, 196, 150))
    for lx in range(12, 150, 20):
        sag = int(5 * math.sin((lx - 12) / 20 * math.pi))
        for k in range(21):
            cv.put(lx + k, 20 + int(4 * math.sin(k / 20 * math.pi)), (70, 56, 50))
        for dy in range(-4, 5):
            for dx in range(-3, 4):
                if (dx / 3) ** 2 + (dy / 4) ** 2 <= 1:
                    cv.put(lx + 10 + dx, 30 + dy + sag // 3, red if dx < 1 else red_dark, tint=False)
        cv.put(lx + 10, 25, gold)
        cv.put(lx + 10, 35, gold)
    return cv


def akashi():
    cv = Canvas("evening")
    sky(cv, 70)
    cloud(cv, 24, 10, 6)
    cloud(cv, 128, 26, 6)
    disc(cv, 110, 58, 6, (255, 220, 150), glow=(255, 190, 120))
    profile(cv, lambda x: 56 - (x - 150) ** 2 * 0.016 if x > 118 else None, 70, forest_color((74, 74, 110)), 118, W)
    profile(cv, lambda x: 62 + 6 * math.sin(x * 0.09 + 0.4) if x < 24 else None, 70, forest_color((84, 80, 112)), 0, 24)
    water(cv, 70, H, (60, 66, 112))
    for y in range(72, 100, 2):
        half = 4 + (y - 70) * 0.35
        start = int(110 - half + noise(y, 0, 2) * 3)
        length = int(half * (0.8 + noise(y, 1, 2) * 0.8))
        for x in range(start, start + length):
            cv.put(x, y, mix(cv.get(x, y), (255, 210, 140), 0.55), tint=False)
    steel, steel_dark, steel_light = (206, 214, 228), (140, 150, 176), (240, 244, 252)
    deck_y = 62
    bridge = {}
    for tx in (42, 118):
        for y in range(6, 84):
            half = 3 if y > 14 else 2
            for k in range(-half, half + 1):
                bridge[(tx + k, y)] = steel if k < 1 else steel_dark
        for y in range(6, 84, 7):
            for k in range(-5, 6):
                bridge[(tx + k, y)] = steel_light if y % 14 == 6 else steel
        for y in range(20, 80, 10):
            for k in range(-4, 5):
                bridge[(tx + k, y + 4)] = steel_dark
    for x in range(-4, W + 4):
        if 42 <= x <= 118:
            cy = 56 - 48 * ((x - 80) / 38) ** 2
        elif x < 42:
            cy = 8 + (42 - x) * 54 / 46
        else:
            cy = 8 + (x - 118) * 54 / 46
        cy = int(min(cy, deck_y - 1))
        bridge[(x, cy)] = steel_light
        bridge[(x, cy + 1)] = steel_dark
        if x % 4 == 0:
            for y in range(cy + 2, deck_y):
                bridge[(x, y)] = (176, 186, 206)
    for x in range(-4, W + 4):
        bridge[(x, deck_y)] = steel_light
        bridge[(x, deck_y + 1)] = steel
        bridge[(x, deck_y + 2)] = steel_dark
        if x % 3 == 0:
            bridge[(x, deck_y + 3)] = steel_dark
    draw(cv, bridge)
    reflect(cv, {k: v for k, v in bridge.items() if k[1] < 70}, 70, 70, H, (60, 66, 112), 0.35)
    for x in range(W):
        for y in range(96, H):
            if noise(x, y, 8) > 0.9:
                cv.put(x, y, (255, 214, 160), tint=False)
    boat_x = 124
    for dx in range(0, 16):
        for dy in range(0, 3):
            cv.put(boat_x + dx - dy // 2 * (0 if dx < 14 else 1), 84 + dy, (60, 50, 64) if dy else (230, 220, 210))
    for y in range(72, 84):
        cv.put(boat_x + 6, y, (230, 220, 210))
    for y in range(74, 82):
        for dx in range(0, 7 - (y - 74)):
            cv.put(boat_x + 7 + dx, y, (252, 240, 224))
    return cv


def okayama():
    cv = Canvas("day")
    sky(cv, 60)
    cloud(cv, 30, 14, 7)
    cloud(cv, 126, 10, 5)
    profile(cv, lambda x: 46 + 5 * math.sin(x * 0.05 + 1.2), 72, forest_color((92, 134, 112), False))
    stone, stone_dark, stone_light = (150, 146, 138), (104, 100, 94), (184, 180, 170)
    black, black_dark, black_light, wall = (46, 44, 52), (26, 26, 32), (86, 84, 96), (246, 244, 238)
    gold = (240, 196, 70)
    cx, base = 84, 70
    castle = {}
    for y in range(base - 12, base):
        t = (y - (base - 12)) / 12
        hw = 26 + 8 * t ** 2
        for x in range(int(cx - hw), int(cx + hw) + 1):
            row = (y - base) // 3
            c = stone_dark if (y - base) % 3 == 0 or (x + row * 3) % 7 == 0 else stone
            if x > cx + hw * 0.5:
                c = shade(c, 0.85)
            castle[(x, y)] = c
    y = base - 12
    for tier, (w, h, upper) in enumerate(((36, 9, False), (28, 8, False), (22, 7, True))):
        half = w // 2
        for yy in range(y - h, y):
            for x in range(cx - half, cx + half + 1):
                c = black if x < cx + half * 0.4 else black_dark
                if upper and yy < y - 2:
                    c = wall if x < cx + half * 0.4 else (214, 214, 214)
                if (x - cx) % 6 == 0 and not upper:
                    c = black_light
                if (yy - y) % 4 == 2 and (x - cx) % 6 in (2, 3) and not upper:
                    c = (200, 190, 120)
                castle[(x, yy)] = c
        y -= h
        eave = half + 4
        for i in range(3):
            span = eave - i * 2
            for x in range(cx - span, cx + span + 1):
                c = black_light if i == 2 else black if i == 1 else black_dark
                castle[(x, y - i)] = shade(c, 0.85) if x > cx + span * 0.5 else c
        if tier == 0:
            for i in range(5):
                for x in range(cx - 9 + i, cx + 10 - i):
                    castle[(x, y - 3 - i)] = wall if i < 4 else black_light
            for x in range(cx - 10, cx + 11):
                castle[(x, y - 3)] = black_dark
            y -= 2
        y -= 3
    for x in range(cx - 7, cx + 8):
        castle[(x, y)] = black_dark
    for k in range(3):
        castle[(cx - 8 - k, y - 1 - k)] = gold
        castle[(cx + 8 + k, y - 1 - k)] = gold
    for dy in range(4):
        castle[(cx, y - 1 - dy)] = gold
    draw(cv, castle)
    ground(cv, 70, (110, 164, 90))
    for y in range(70, 78):
        for x in range(W):
            c = (88, 138, 76) if noise(x // 2, y, 3) > 0.2 else (104, 156, 84)
            cv.put(x, y, c)
    water(cv, 78, 100, (46, 110, 150))
    for x in range(W):
        for y in range(70, 78):
            cv.put(x, y, (122, 172, 96) if noise(x, y, 2) > 0.3 else (96, 148, 82))
    for x in range(W):
        cv.put(x, 78, (150, 146, 138))
    water(cv, 79, 100, (46, 110, 150))
    for x in range(52, 108):
        arch = abs(x - 80)
        top = 84 - int(8 * math.sqrt(max(0, 1 - (arch / 28) ** 2)))
        for y in range(top, top + 3):
            cv.put(x, y, (176, 170, 158) if y == top else (130, 124, 114))
    for lx, ly in ((20, 90), (142, 92), (112, 96)):
        for dy in range(3):
            for dx in range(-4, 5):
                if abs(dx) + dy * 2 <= 5:
                    cv.put(lx + dx, ly + dy, (80, 150, 80) if dy else (120, 190, 100))
    for y in range(100, H):
        for x in range(W):
            n = noise(x // 2, y, 6)
            cv.put(x, y, (104, 158, 84) if n > 0.2 else (84, 136, 70))
    for px, py, h in ((14, 99, 34), (150, 99, 38), (58, 100, 0), (112, 100, 0)):
        if h:
            pine(cv, px, py, h, flip=px > 80)
    for k in range(7):
        x = 24 + k * 16
        for dy in range(3):
            for dx in range(-3, 4):
                if abs(dx) + dy <= 3:
                    cv.put(x + dx, 93 + dy, (236, 120, 150) if (dx + dy) % 3 else (252, 200, 214))
    return cv


def onomichi():
    cv = Canvas("day")
    sky(cv, 52)
    cloud(cv, 112, 10, 6)
    cloud(cv, 142, 22, 4)
    water(cv, 52, H, (50, 110, 160))
    profile(cv, lambda x: 34 + 6 * math.sin(x * 0.07) if 70 < x < 150 else None, 52, forest_color((96, 130, 128)), 70, 150)
    profile(cv, lambda x: 40 + 4 * math.sin(x * 0.1 + 1) if x > 118 else None, 52, forest_color((78, 120, 100)), 118, W)
    water(cv, 52, H, (50, 110, 160))
    bridge = {}
    for x in range(60, 160):
        bridge[(x, 50)] = (240, 240, 244)
        bridge[(x, 51)] = (160, 170, 190)
    for px in (86, 124):
        for y in range(36, 52):
            bridge[(px, y)] = (236, 236, 242)
            bridge[(px + 1, y)] = (170, 180, 196)
    for x in range(86, 125):
        bridge[(x, 36 + int(12 * ((x - 105) / 19) ** 2))] = (236, 236, 242)
    draw(cv, bridge)
    hill, hill_dark = (96, 150, 80), (72, 118, 66)
    for y in range(34, H):
        edge = 66 - int((y - 34) * 0.62)
        for x in range(0, max(0, edge)):
            n = noise(x, y, 3)
            cv.put(x, y, hill if n > 0.25 else hill_dark)
    houses = [(2, 50, 14, 10, (236, 224, 196), (178, 96, 66)), (18, 58, 12, 9, (214, 196, 160), (96, 100, 112)),
              (8, 66, 16, 10, (240, 230, 210), (96, 100, 112)), (28, 70, 14, 9, (228, 206, 176), (190, 110, 70)),
              (2, 76, 14, 10, (214, 196, 160), (178, 96, 66)), (20, 82, 16, 10, (240, 230, 210), (96, 100, 112)),
              (40, 84, 12, 9, (228, 206, 176), (178, 96, 66)), (6, 90, 14, 9, (236, 224, 196), (96, 100, 112))]
    for hx, hy, hw, hh, wall, roof in houses:
        for y in range(hy, hy + hh):
            for x in range(hx, hx + hw):
                c = wall if x < hx + hw - 2 else shade(wall, 0.84)
                if (y - hy) % 5 == 2 and (x - hx) % 5 in (2, 3):
                    c = (70, 66, 74)
                cv.put(x, y, c)
        for i in range(4):
            for x in range(hx - 1 + i, hx + hw + 1 - i):
                cv.put(x, hy - 1 - i, roof if i < 3 else mix(roof, (255, 255, 255), 0.3))
    for y in range(40, 60):
        for x in range(64 - (y - 40) // 4, 70 - (y - 40) // 4):
            if y % 5:
                cv.put(x, y, (120, 82, 60))
    for i in range(5):
        for x in range(32 + i * 2, 54 - i * 2):
            cv.put(x, 34 - i, (170, 60, 50) if i < 4 else (240, 240, 232))
    for y in range(34, 44):
        for x in range(36, 56):
            cv.put(x, y, (240, 232, 214) if x < 52 else (212, 202, 184))
    for x in range(32, 60):
        for k in range(2):
            cv.put(x, 33 - k - (1 if abs(x - 46) > 11 else 0), (170, 60, 50))
    for step in range(12):
        sy = 72 + step * 2
        for x in range(46 + step * 2, 76 + step * 2):
            if sy + 1 < H:
                cv.put(x, sy, (200, 192, 174) if step % 2 else (170, 160, 142))
    ship = {}
    for dx in range(0, 30):
        for dy in range(0, 5):
            if dx < 4 and dy < 2 or dx > 27 and dy > 3:
                continue
            ship[(104 + dx, 80 + dy)] = (236, 236, 240) if dy < 3 else (190, 60, 56)
    for dx in range(6, 22):
        ship[(104 + dx, 79)] = (236, 236, 240)
        if dx < 16:
            ship[(104 + dx, 78)] = (210, 214, 226)
    for dx in range(10, 14):
        for dy in range(74, 78):
            ship[(104 + dx, dy)] = (214, 78, 60)
    draw(cv, ship)
    reflect(cv, ship, 85, 85, H, (50, 110, 160), 0.4)
    for dx, dy in ((0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (3, 0), (0, -1), (2, -1)):
        cv.put(34 + dx, 88 + dy, (210, 170, 110))
    cv.put(37, 89, (60, 44, 40))
    return cv


def tram(cv, x, y, body, stripe):
    out, glass, glass_dark = (40, 40, 46), (96, 140, 180), (64, 100, 140)
    for yy in range(y, y + 20):
        for xx in range(x, x + 64):
            corner = (xx < x + 2 or xx > x + 61) and (yy < y + 2 or yy > y + 17)
            if corner:
                continue
            c = body
            if yy in (y, y + 1):
                c = shade(body, 1.2)
            elif yy >= y + 14:
                c = stripe
            elif 3 <= yy - y <= 9 and (xx - x - 3) % 11 < 8 and 3 <= xx - x <= 60:
                c = glass if yy - y < 7 else glass_dark
            cv.put(xx, yy, c)
    for k in range(2):
        for yy in range(y + 3, y + 10):
            cv.put(x + 62 + k, yy, glass_dark)
    for yy in range(y - 3, y):
        for xx in range(x + 20, x + 44):
            cv.put(xx, yy, shade(body, 0.8))
    for xx in range(x + 26, x + 38):
        cv.put(xx, y - 2, (255, 214, 120), tint=False)
    for wx in (x + 8, x + 48):
        for yy in range(y + 18, y + 23):
            for xx in range(wx, wx + 8):
                if (xx - wx - 3.5) ** 2 + (yy - y - 20) ** 2 <= 12:
                    cv.put(xx, yy, out)
    for xx in range(x + 18, x + 24):
        cv.put(xx, y + 16, (255, 224, 140), tint=False)
    for yy in range(y - 12, y - 3):
        cv.put(x + 30 + (y - 3 - yy) // 2, yy, out)
        cv.put(x + 31 + (y - 3 - yy) // 2, yy, out)


def hiroshima():
    cv = Canvas("morning")
    sky(cv, 52)
    cloud(cv, 34, 12, 6)
    cloud(cv, 120, 18, 6)
    profile(cv, lambda x: 30 + 10 * math.sin(x * 0.03 + 2.0) + 2 * math.sin(x * 0.22), 56, forest_color((78, 124, 100), False))
    for k, (x0, x1, top, wall) in enumerate(((0, 14, 38, (214, 214, 220)), (14, 30, 44, (232, 226, 214)),
                                             (30, 42, 34, (200, 206, 218)), (42, 62, 46, (226, 214, 198)),
                                             (100, 116, 40, (208, 212, 224)), (116, 134, 32, (232, 226, 214)),
                                             (134, 148, 44, (214, 214, 220)), (148, 164, 36, (200, 206, 218))), start=0):
        for y in range(top, 58):
            for x in range(x0, x1):
                c = wall if x < x1 - 2 else shade(wall, 0.82)
                if (y - top) % 5 in (1, 2) and (x - x0) % 4 in (1, 2) and y > top + 2:
                    c = (110, 138, 170)
                cv.put(x, y, c)
    water(cv, 56, 68, (60, 120, 150))
    for x in range(W):
        cv.put(x, 68, (150, 160, 150))
        cv.put(x, 69, (118, 128, 120))
    for y in range(70, H):
        for x in range(W):
            n = noise(x // 2, y, 5)
            cv.put(x, y, (124, 124, 132) if n > 0.2 else (110, 110, 120))
    for x in range(W):
        cv.put(x, 74, (172, 172, 176))
    for x in range(0, W, 3):
        cv.put(x, 94, (212, 210, 200))
    for rail in (88, 92):
        for x in range(W):
            cv.put(x, rail, (176, 176, 184))
            cv.put(x, rail + 1, (88, 88, 96))
    for x in range(0, W, 4):
        for rail in (89, 93):
            cv.put(x, rail + 1, (110, 92, 74))
    for px in (14, 112, 150):
        for y in range(18, 76):
            cv.put(px, y, (70, 66, 72))
        for x in range(px - 3, px + 4):
            cv.put(x, 20, (70, 66, 72))
    for x in range(W):
        cv.put(x, 23 + int(1.5 * math.sin(x * 0.04)), (70, 66, 72), tint=False)
        cv.put(x, 40 + int(1.5 * math.sin(x * 0.04)), (70, 66, 72), tint=False)
    tram(cv, 48, 66, (216, 218, 214), (60, 150, 100))
    for x in range(W):
        for y in range(96, H):
            if noise(x, y, 8) > 0.93:
                cv.put(x, y, (190, 190, 196))
    return cv


def yatai(cv, x, awning, glow):
    wood, wood_dark = (130, 88, 60), (84, 56, 42)
    for y in range(66, 88):
        for xx in range(x, x + 34):
            cv.put(xx, y, wood if (xx + y // 4) % 6 else wood_dark)
    for y in range(66, 76):
        for xx in range(x + 2, x + 32):
            cv.put(xx, y, (255, 226, 150), tint=False)
            if (xx - x) % 10 == 0:
                cv.put(xx, y, wood_dark)
    for xx in range(x - 3, x + 37):
        cv.put(xx, 64, wood_dark)
        cv.put(xx, 65, wood)
        cv.put(xx, 77, (210, 176, 120))
        cv.put(xx, 78, wood_dark)
    for i in range(5):
        for xx in range(x - 4 + i, x + 38 - i):
            band = ((xx - x) // 4) % 2
            cv.put(xx, 63 - i, awning[band] if i < 4 else mix(awning[0], (255, 255, 255), 0.3))
    for xx in range(x + 2, x + 32):
        for y in range(79, 84):
            if (xx - x) % 8 < 6:
                cv.put(xx, y, awning[((xx - x) // 8) % 2], tint=False)
    for k in range(3):
        bx = x + 7 + k * 9
        for dx in range(-2, 3):
            cv.put(bx + dx, 75, (240, 236, 228))
            cv.put(bx + dx, 74, (196, 150, 90) if abs(dx) < 2 else (240, 236, 228))
    for dx in range(-3, 4):
        for dy in range(-3, 4):
            if abs(dx) + abs(dy) <= 3:
                cv.put(x + 2 + dx, 69 + dy, glow, tint=False)
                cv.put(x + 32 + dx, 69 + dy, glow, tint=False)
    for sx in (x + 4, x + 14, x + 24):
        for y in range(90, 98):
            cv.put(sx, y, (96, 66, 50))
            cv.put(sx + 1, y, (96, 66, 50))
        for dx in range(-2, 5):
            cv.put(sx + dx, 89, (200, 74, 62))
    for sx in (x + 10, x + 20):
        for i in range(6):
            cv.put(sx + int(1.5 * math.sin(i * 0.9)), 60 - i, (230, 230, 236), tint=False)


def hakata():
    cv = Canvas("night")
    sky(cv, 40)
    for x0, x1, top, wall in ((0, 16, 24, (64, 70, 108)), (16, 28, 34, (78, 62, 96)), (28, 50, 28, (58, 72, 100)),
                              (50, 62, 36, (84, 66, 90)), (62, 84, 18, (60, 66, 104)), (84, 100, 32, (76, 64, 94)),
                              (100, 126, 26, (58, 74, 100)), (126, 140, 36, (82, 66, 92)), (140, 160, 22, (62, 68, 106))):
        for y in range(top, 52):
            for x in range(x0, x1):
                c = wall
                if (y - top) % 4 in (1, 2) and (x - x0) % 4 in (1, 2) and y > top + 2:
                    c = (255, 218, 130) if noise(x // 4, y // 4, x0) > 0.35 else shade(wall, 0.7)
                cv.put(x, y, c, tint=False)
    for x in (22, 56, 92, 134):
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                if abs(dx) + abs(dy) <= 3:
                    cv.put(x + dx, 40 + dy, (255, 226, 140), tint=False)
    water(cv, 52, 62, (26, 30, 70))
    for x in range(W):
        cv.put(x, 62, (90, 84, 120))
        cv.put(x, 63, (60, 56, 84))
    for y in range(64, H):
        for x in range(W):
            n = noise(x // 2, y, 5)
            cv.put(x, y, (84, 78, 98) if n > 0.2 else (70, 66, 86))
    for x in range(W):
        for y in range(64, 66):
            cv.put(x, y, (120, 110, 130))
    yatai(cv, 6, ((214, 70, 56), (246, 240, 224)), (255, 120, 90))
    yatai(cv, 62, ((60, 110, 190), (246, 240, 224)), (255, 190, 100))
    yatai(cv, 118, ((236, 168, 40), (246, 240, 224)), (255, 150, 80))
    for x in range(W):
        for y in range(98, H):
            if noise(x, y, 8) > 0.92:
                cv.put(x, y, (255, 200, 140), tint=False)
    return cv


SCENES = {
    "dotonbori": dotonbori,
    "nankinmachi": nankinmachi,
    "akashi": akashi,
    "okayama": okayama,
    "onomichi": onomichi,
    "hiroshima": hiroshima,
    "hakata": hakata,
}
