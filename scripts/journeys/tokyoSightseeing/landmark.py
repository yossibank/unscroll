import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, mix, moon, noise, pine, shade, sky, water


def rect(cv, x0, y0, x1, y1, c, tint=True):
    for y in range(y0, y1):
        for x in range(x0, x1):
            cv.put(x, y, c, tint=tint)


def towers(cv, base, top_min, top_max, color, seed, lit=False):
    x, i = 0, 0
    while x < W:
        bw = 9 + int(noise(i, 0, seed) * 9)
        top = base - (top_min + int(noise(i, 1, seed) * (top_max - top_min)))
        rect(cv, x, top, x + bw, base, color if i % 2 else shade(color, 0.92))
        for y in range(top + 2, base - 1, 3):
            for xx in range(x + 1, x + bw - 1, 3):
                if lit:
                    if noise(xx, y, seed + 1) > 0.45:
                        cv.put(xx, y, (255, 226, 150), tint=False)
                else:
                    cv.put(xx, y, shade(color, 0.8))
        x += bw
        i += 1


def kokyo():
    cv = Canvas("day")
    sky(cv, 52)
    cloud(cv, 34, 14, 6)
    cloud(cv, 128, 24, 5)
    towers(cv, 50, 8, 22, (168, 186, 206), 3)
    wall = (184, 180, 168)
    for y in range(50, 70):
        shift = (y // 4) * 5
        for x in range(W):
            c = wall
            if y % 4 == 0 or (x + shift) % 11 == 0:
                c = shade(wall, 0.72)
            elif noise(x, y, 5) > 0.9:
                c = mix(wall, (230, 226, 214), 0.5)
            cv.put(x, y, c)
    rect(cv, 0, 50, W, 52, (150, 164, 112))
    plaster, roof, roof_dark = (240, 238, 228), (92, 132, 118), (62, 98, 90)
    rect(cv, 66, 40, 102, 50, plaster)
    for x in range(70, 100, 7):
        rect(cv, x, 43, x + 3, 47, (70, 70, 78))
    for k in range(5):
        rect(cv, 62 + k, 36 + k, 106 - k, 37 + k, roof if k < 4 else roof_dark)
    rect(cv, 74, 28, 94, 36, plaster)
    for x in (78, 86):
        rect(cv, x, 30, x + 4, 34, (70, 70, 78))
    for k in range(7):
        rect(cv, 70 + k, 21 + k, 98 - k, 22 + k, roof if k < 6 else roof_dark)
    rect(cv, 83, 17, 85, 22, (226, 196, 90))
    pine(cv, 24, 54, 34)
    pine(cv, 140, 54, 30, flip=True)
    pine(cv, 46, 54, 22)
    pine(cv, 120, 54, 24, flip=True)
    water(cv, 70, H, (52, 104, 98))
    deck = (206, 202, 190)
    for y in range(80, 94):
        for x in range(30, 130):
            hole = any(((x - cx) / 14) ** 2 + ((y - 94) / 12) ** 2 < 1 for cx in (50, 80, 110))
            if hole:
                cv.put(x, y, (62, 78, 80) if (x + y) % 5 else (80, 100, 100))
            else:
                c = deck
                if (y - 80) % 4 == 0 or (x + (y // 4) * 3) % 8 == 0:
                    c = shade(deck, 0.82)
                cv.put(x, y, c)
    rect(cv, 30, 76, 130, 80, deck)
    for x in range(30, 130, 4):
        rect(cv, x, 72, x + 2, 76, mix(deck, (255, 255, 255), 0.35))
    rect(cv, 30, 72, 130, 73, shade(deck, 0.85))
    for x in (30, 78, 126):
        rect(cv, x, 66, x + 4, 76, shade(deck, 0.9))
        rect(cv, x - 1, 65, x + 5, 66, mix(deck, (255, 255, 255), 0.4))
    for dx, dy in (
        (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (1, 1), (2, 1), (3, 1),
        (-1, -1), (-1, -2), (-1, -3), (-1, -4), (0, -5), (-1, -5),
    ):
        cv.put(138 + dx, 90 + dy, (252, 252, 250), tint=False)
    cv.put(-2 + 138, 90 - 5, (240, 150, 60), tint=False)
    return cv


def asakusa():
    cv = Canvas("day")
    sky(cv, 70)
    cloud(cv, 24, 10, 5)
    cloud(cv, 136, 14, 5)
    px = 147
    for tier in range(5):
        y = 62 - tier * 8
        half = 11 - tier * 2
        rect(cv, px - half + 2, y, px + half - 1, y + 5, (214, 98, 70))
        for k in range(3):
            rect(cv, px - half - 1 + k, y - 3 + k, px + half + 2 - k, y - 2 + k, (74, 82, 90))
    rect(cv, px, 14, px + 1, 22, (226, 196, 90))
    for y in range(70, H):
        for x in range(W):
            tile = (x // 10 + y // 5) % 2
            cv.put(x, y, (196, 190, 178) if tile else (178, 172, 160))
    for x in range(W):
        cv.put(x, 70, (140, 134, 124))
    red, red_dark, black = (210, 58, 44), (150, 36, 34), (46, 40, 40)
    for y in range(46, 74):
        for x in range(34, 124):
            c = (200, 224, 240) if y < 56 else (190, 160, 128)
            cv.put(x, y, c)
    for x in range(40, 120, 8):
        for k in range(2):
            cv.put(x + k, 60 + (x // 8) % 2, (226, 70, 56), tint=False)
    for sx, tone in ((50, (96, 160, 110)), (98, (206, 64, 54))):
        rect(cv, sx, 52, sx + 10, 74, (80, 56, 50))
        rect(cv, sx + 2, 56, sx + 8, 74, tone)
        rect(cv, sx + 3, 52, sx + 7, 56, (240, 214, 176))
    for pillar in (24, 124):
        for y in range(36, 74):
            for k in range(10):
                cv.put(pillar + k, y, red if k < 8 else red_dark)
        rect(cv, pillar - 2, 72, pillar + 12, 76, (176, 170, 158))
    rect(cv, 34, 36, 124, 44, red)
    rect(cv, 34, 44, 124, 46, red_dark)
    for x in range(34, 124):
        cv.put(x, 41, (232, 190, 90))
    for x in range(34, 124, 6):
        rect(cv, x, 36, x + 1, 41, red_dark)
    roof, roof_light = (66, 72, 82), (112, 120, 130)
    for k in range(10):
        for x in range(int(18 + k * 1.6), int(142 - k * 1.6)):
            c = roof_light if k == 9 else shade(roof, 1.25) if k % 3 == 2 else roof
            cv.put(x, 36 - k, c)
    for k in range(5):
        for x in range(8 + k, 20):
            cv.put(x, 36 - k // 2, roof)
            cv.put(159 - x, 36 - k // 2, roof)
    for k in range(4):
        cv.put(8 + k, 33 - k, roof_light)
        cv.put(151 - k, 33 - k, roof_light)
    rect(cv, 8, 36, 152, 39, roof)
    rect(cv, 8, 38, 152, 40, shade(roof, 0.8))
    for x in range(8, 152, 4):
        cv.put(x, 38, roof_light)
    lc = 79
    rect(cv, lc - 1, 40, lc + 3, 49, black)
    for y in range(49, 70):
        t = (y - 49) / 20
        hw = int(13 * math.sqrt(max(0.0, 1 - ((t - 0.5) * 2) ** 2 * 0.55)))
        for x in range(lc + 1 - hw, lc + 1 + hw + 1):
            c = (222, 52, 44)
            if x > lc + hw * 0.4:
                c = (176, 34, 34)
            if (y - 49) % 5 == 4:
                c = black
            elif (x - lc) % 6 in (2, 3) and 51 < y < 66:
                c = (250, 244, 232) if y % 2 else black
            cv.put(x, y, c, tint=False)
    rect(cv, lc - 8, 68, lc + 10, 71, black)
    return cv


def skytree():
    cv = Canvas("evening")
    sky(cv, 76)
    cloud(cv, 30, 22, 6)
    cloud(cv, 134, 40, 5)
    disc(cv, 30, 58, 6, (255, 230, 170), glow=(255, 200, 140))
    towers(cv, 78, 6, 18, (112, 96, 128), 6)
    cx = 98

    def half(y):
        if y < 18:
            return 1
        if y < 38:
            return 2
        return 2.5 + ((y - 38) / 38) ** 1.7 * 9

    lit, dark = (232, 240, 248), (150, 164, 196)
    for y in range(4, 76):
        hw = half(y)
        for x in range(int(cx - hw), int(cx + hw) + 1):
            c = dark if x > cx + hw * 0.1 else lit
            if hw > 3 and (x + y) % 3 == 0:
                c = shade(c, 0.82)
            cv.put(x, y, c, tint=False)
    for y0, hw, h in ((22, 8, 5), (31, 6, 4)):
        for y in range(y0, y0 + h):
            for x in range(cx - hw, cx + hw + 1):
                c = (214, 224, 236) if y < y0 + h - 1 else (110, 122, 156)
                if y == y0 + 2 and x % 2 == 0:
                    c = (255, 232, 160)
                cv.put(x, y, c, tint=False)
    rect(cv, cx - 1, 4, cx + 1, 8, (255, 90, 80), tint=False)
    for y in range(1, 18):
        cv.put(cx, y, (214, 224, 236), tint=False)
    water(cv, 80, H, (60, 66, 112))
    towers(cv, 82, 6, 12, (92, 80, 108), 8)
    rect(cv, 0, 82, W, 84, (74, 66, 88))
    for x in range(0, W, 6):
        rect(cv, x, 80, x + 1, 82, (74, 66, 88))
    for x in range(10, W, 18):
        cv.put(x, 86 + (x // 18) % 3, (255, 214, 150), tint=False)
    for y in range(84, 94):
        for dx in range(-3, 4):
            if noise(cx + dx, y, 6) > 0.5 and y % 2 == 0:
                cv.put(cx + dx, y, mix(cv.get(cx + dx, y), (230, 238, 248), 0.4), tint=False)
    rect(cv, 0, 94, W, H, (74, 70, 96))
    for x in range(0, W, 8):
        rect(cv, x, 94, x + 1, 100, (60, 56, 80))
    rect(cv, 0, 92, W, 94, (116, 110, 132))
    return cv


def odaiba():
    cv = Canvas("night")
    sky(cv, 58)
    moon(cv, 134, 14)
    towers(cv, 58, 6, 20, (46, 54, 90), 9, lit=True)
    water(cv, 58, H, (14, 30, 70))
    cable, hanger = (222, 226, 234), (150, 160, 184)
    deck_y, left, right = 54, 44, 112

    def hang(x, y):
        cv.put(x, y, cable, tint=False)
        if x % 4 == 0:
            for hy in range(y + 1, deck_y):
                cv.put(x, hy, hanger, tint=False)
        if x % 8 == 0:
            cv.put(x, y, (255, 244, 190), tint=False)

    for tx in (left, right):
        for y in range(14, 54):
            rect(cv, tx - 2, y, tx + 2, y + 1, (190, 196, 210), tint=False)
            cv.put(tx + 1, y, (130, 138, 160), tint=False)
        rect(cv, tx - 3, 14, tx + 3, 16, (206, 212, 224), tint=False)
        rect(cv, tx - 3, 32, tx + 3, 33, (206, 212, 224), tint=False)
    rect(cv, 0, deck_y, W, deck_y + 2, (180, 186, 202), tint=False)
    rect(cv, 0, deck_y + 2, W, deck_y + 3, (96, 104, 130), tint=False)
    for x in range(0, W, 6):
        rect(cv, x, deck_y + 3, x + 2, deck_y + 8, (96, 104, 130), tint=False)
        cv.put(x + 1, deck_y - 1, (255, 238, 170), tint=False)
    for x in range(left, right + 1):
        t = (x - left) / (right - left)
        hang(x, int(15 + 25 * (1 - (2 * t - 1) ** 2)))
    for x in range(0, left):
        hang(x, int(deck_y - 2 - (deck_y - 18) * x / left))
    for x in range(right + 1, W):
        hang(x, int(15 + (deck_y - 17) * (x - right) / (W - right)))
    for y in range(deck_y + 9, H):
        for x in range(W):
            if y > 62 and (x + y * 3) % 17 == 0 and y % 3 == 0:
                cv.put(x, y, mix(cv.get(x, y), (255, 236, 170), 0.5), tint=False)
    for tx in (left, right):
        for y in range(deck_y + 9, H, 2):
            for dx in range(-1, 2):
                cv.put(tx + dx, y, mix(cv.get(tx + dx, y), (200, 206, 230), 0.4), tint=False)
    rect(cv, 0, 84, 46, H, (40, 52, 70))
    rect(cv, 0, 84, 46, 86, (74, 86, 104))
    for x in range(0, 46, 6):
        rect(cv, x, 86, x + 1, H, (30, 40, 56))
    pedestal = (150, 156, 170)
    rect(cv, 12, 74, 28, 84, pedestal, tint=False)
    rect(cv, 10, 82, 30, 84, shade(pedestal, 0.8), tint=False)
    rect(cv, 14, 70, 26, 74, shade(pedestal, 1.1), tint=False)
    green, green_dark, gold = (120, 200, 176), (78, 144, 130), (255, 214, 96)
    for y in range(52, 70):
        hw = 2 + (y - 52) / 18 * 4
        for x in range(int(20 - hw), int(20 + hw) + 1):
            cv.put(x, y, green if x < 20 + hw * 0.3 else green_dark, tint=False)
    rect(cv, 18, 44, 23, 52, green, tint=False)
    for k in range(5):
        cv.put(16 + k * 2, 42 - k % 2, green_dark, tint=False)
    for y in range(34, 50):
        cv.put(26 + (49 - y) // 8, y, green, tint=False)
    for dx, dy in ((0, 0), (1, 0), (0, -1), (1, -1), (0, -2)):
        cv.put(27 + dx, 31 + dy, gold, tint=False)
    cv.put(27, 28, (255, 240, 170), tint=False)
    return cv


def tokyotower():
    cv = Canvas("evening")
    sky(cv, 80)
    cloud(cv, 34, 22, 6)
    cloud(cv, 128, 44, 5)
    disc(cv, 132, 64, 5, (255, 224, 160), glow=(255, 190, 130))
    towers(cv, 80, 6, 20, (118, 98, 128), 12)
    cx = 80
    orange, white = (232, 84, 44), (250, 244, 236)

    def half(y):
        if y < 20:
            return 0.6
        if y < 38:
            return 1.5 + (y - 20) / 18 * 3.5
        if y < 44:
            return 12
        return 6 + ((y - 44) / 32) ** 1.4 * 20

    for y in range(2, 76):
        hw = half(y)
        tone = orange if ((y - 2) // 6) % 2 == 0 else white
        for x in range(int(cx - hw), int(cx + hw) + 1):
            edge = abs(x - cx) >= hw - 1.4
            brace = (x + y) % 5 == 0 or (x - y) % 5 == 0
            inner = abs(x - cx) < 1 and y > 44
            if y < 20:
                cv.put(x, y, tone)
            elif 38 <= y < 44:
                cv.put(x, y, orange if y in (38, 43) else (255, 232, 160))
            elif edge or brace or inner:
                cv.put(x, y, tone if x <= cx else shade(tone, 0.82))
    for y in range(20, 26):
        for x in range(cx - 7, cx + 8):
            cv.put(x, y, orange if y in (20, 25) else (255, 232, 160))
    cv.put(cx, 1, (255, 120, 90), tint=False)
    rect(cv, cx - 30, 72, cx + 31, 80, (208, 200, 196))
    rect(cv, cx - 30, 72, cx + 31, 74, (190, 70, 60))
    for x in range(cx - 28, cx + 29, 6):
        rect(cv, x, 75, x + 3, 78, (70, 76, 96))
    for y in range(80, H):
        for x in range(W):
            cv.put(x, y, (86, 142, 84) if noise(x, y, 4) > 0.14 else (64, 114, 70))
    for x in range(W):
        cv.put(x, 80, (150, 190, 110))
    for x in range(52, 108):
        t = (x - 52) / 56
        cv.put(x, 84 + int(10 * t * t), (214, 200, 164))
        cv.put(x, 85 + int(10 * t * t), (190, 176, 142))
    pine(cv, 20, 94, 38)
    pine(cv, 140, 96, 34, flip=True)
    pine(cv, 40, 84, 20)
    for x in (30, 118, 134):
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, -1), (0, 1)):
            cv.put(x + dx, 95 + dy, (255, 150, 170) if (dx, dy) != (0, 0) else (255, 222, 120))
    return cv


SCENES = {
    "kokyo": kokyo,
    "asakusa": asakusa,
    "skytree": skytree,
    "odaiba": odaiba,
    "tokyotower": tokyotower,
}
