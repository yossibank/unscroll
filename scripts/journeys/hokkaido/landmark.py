import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, forest_color, ground, mix, moon, noise, pine, profile, shade, sky, water


def rect(cv, x0, y0, x1, y1, c, tint=True):
    for y in range(y0, y1):
        for x in range(x0, x1):
            cv.put(x, y, c, tint=tint)


def snowfall(cv, count, seed):
    for n in range(count):
        x, y = int(noise(n, 1, seed) * W), int(noise(n, 2, seed) * H)
        cv.put(x, y, (255, 255, 255), tint=False)
        if n % 3 == 0:
            cv.put(x + 1, y, (226, 236, 248), tint=False)


def hakodate():
    cv = Canvas("night")
    sky(cv, 54)
    moon(cv, 126, 16)
    for x in range(W):
        top = 40 - int(14 * max(0.0, 1 - abs(x - 30) / 44) ** 0.8) + int(2 * math.sin(x * 0.4))
        for y in range(top, 54):
            cv.put(x, y, (22, 28, 52) if y > top else (40, 52, 84), tint=False)
    for x in range(W):
        for y in range(54, H):
            cv.put(x, y, (14, 24, 54) if noise(x // 2, y, 6) > 0.1 else (20, 34, 70), tint=False)
    for x in range(8, W, 7):
        for k in range(2):
            cv.put(x + k, 55, (255, 226, 150), tint=False)
        cv.put(x, 56, (220, 170, 90), tint=False)
    cx = 84
    for y in range(58, H):
        if y < 68:
            hw = 14 + (68 - y) * 1.2
        else:
            hw = 14 + (y - 68) ** 1.15 * 1.9
        for x in range(int(cx - hw), int(cx + hw) + 1):
            r = noise(x, y, 9)
            street = (x * 3 + y * 5) % 11 < 2
            if r > 0.66 or (street and r > 0.3):
                c = (255, 214, 120) if r > 0.8 else (255, 174, 84) if r > 0.74 else (150, 200, 255)
            else:
                c = (24, 24, 44) if r > 0.2 else (34, 34, 60)
            cv.put(x, y, c, tint=False)
    for y in range(58, 70):
        for x in range(int(cx - 14 - (68 - y) * 1.2) - 1, int(cx - 14 - (68 - y) * 1.2) + 1):
            cv.put(x, y, (60, 66, 96), tint=False)
    for i in range(0, 46):
        x, y = 4 + i * 2, 66 + i
        cv.put(x, y, (74, 70, 86), tint=False)
        cv.put(x + 1, y, (96, 90, 104), tint=False)
        cv.put(x + 2, y, (74, 70, 86), tint=False)
        if i % 9 == 4:
            for k in range(1, 5):
                cv.put(x - 3, y - k, (60, 54, 66), tint=False)
            for dx in (-4, -3, -2):
                cv.put(x + dx, y - 5, (255, 226, 150), tint=False)
            cv.put(x - 3, y - 6, (255, 244, 200), tint=False)
    for x in range(0, 52):
        for y in range(88 + x // 6, H):
            cv.put(x, y, (14, 14, 28), tint=False)
    for x in range(8, 46, 11):
        h = 8 + int(noise(x, 3, 3) * 4)
        for y in range(H - h - 4, H - 4):
            for xx in range(x, x + 9):
                cv.put(xx, y, (18, 18, 34), tint=False)
        for xx in range(x - 1, x + 10):
            cv.put(xx, H - h - 5, (30, 30, 52), tint=False)
        cv.put(x + 3, H - h, (255, 214, 120), tint=False)
    return cv


def onuma():
    cv = Canvas("morning")
    sky(cv, 56)
    cloud(cv, 36, 14, 6)
    cloud(cv, 140, 26, 5)

    def peaks(x):
        t = 1 - abs(x - 86) / 78
        if t <= 0:
            return None
        top = 56 - 36 * t ** 0.9
        top += 3 * abs(math.sin(x * 0.45)) * t
        if 78 < x < 94:
            top += 6 * (1 - abs(x - 86) / 8)
        return top

    def rock(x, y, depth):
        if y > 46:
            return forest_color((52, 104, 84))(x, y, depth)
        lit = (150, 156, 172) if x < 88 else (112, 118, 140)
        return mix(lit, (206, 214, 226), 0.2) if depth < 3 else lit if noise(x, y, 2) > 0.2 else shade(lit, 0.85)

    profile(cv, peaks, 56, rock)
    for x in range(W):
        top = 52 + int(3 * math.sin(x * 0.09) + 2 * math.sin(x * 0.31))
        for y in range(top, 58):
            cv.put(x, y, (46, 100, 72) if noise(x // 2, y, 5) > 0.2 else (34, 82, 62))
    water(cv, 58, 82, (60, 128, 170))
    for cx, cy, r in ((48, 68, 11), (112, 72, 14), (136, 66, 7)):
        for y in range(cy - 3, cy + 3):
            for x in range(cx - r, cx + r + 1):
                if ((x - cx) / r) ** 2 + ((y - cy) / 2.6) ** 2 <= 1:
                    cv.put(x, y, (74, 130, 80) if y < cy + 1 else (102, 92, 64))
        pine(cv, cx - r // 3, cy + 1, 14 + r // 2)
    for x in range(52, 108):
        y = 71 - int(5 * math.sin((x - 52) / 56 * math.pi))
        cv.put(x, y, (150, 74, 58))
        cv.put(x, y + 1, (110, 52, 44))
        if x % 4 == 0:
            cv.put(x, y - 1, (110, 52, 44))
            cv.put(x, y - 2, (110, 52, 44))
    ground(cv, 82, (96, 148, 84), seed=4)
    for x in range(0, W, 6):
        for k in range(3):
            cv.put(x + k, 84 + int(noise(x, k, 8) * 8), (236, 196, 120) if noise(x, k, 3) > 0.85 else (126, 176, 96))
    pine(cv, 20, 100, 44)
    pine(cv, 142, 100, 38, flip=True)
    return cv


def toyako():
    cv = Canvas("evening")
    sky(cv, 52)
    disc(cv, 112, 44, 8, (255, 232, 170), glow=(255, 190, 130))
    cloud(cv, 38, 16, 6)

    def rim(x):
        return 42 + 5 * math.sin(x * 0.045 + 0.6) + 2 * math.sin(x * 0.2)

    profile(cv, rim, 54, forest_color((58, 82, 100)))
    for y in range(26, 54):
        t = (y - 26) / 28
        hw = 2 + 24 * t ** 1.5
        for x in range(int(24 - hw), int(24 + hw) + 1):
            c = (214, 200, 216) if y < 34 and x < 25 else (154, 150, 176) if x < 26 else (118, 116, 148)
            if y >= 44:
                c = mix(c, (58, 82, 100), 0.5)
            cv.put(x, y, c)
    water(cv, 54, H, (40, 80, 140))
    for y in range(54, H):
        for x in range(96 - (y - 54) // 4, 128 + (y - 54) // 4):
            if (x + y) % 3 == 0 and abs(x - 112) < 4 + (y - 54) // 3:
                cv.put(x, y, mix(cv.get(x, y), (255, 214, 150), 0.55), tint=False)
    for x in range(36, 134):
        t = (x - 36) / 98
        top = 62 - int(14 * math.sin(math.pi * t) ** 0.8)
        for y in range(top, 66):
            c = (36, 84, 62) if noise(x // 2, y // 2, 3) > 0.25 else (26, 64, 50)
            if y == top:
                c = (78, 126, 80)
            cv.put(x, y, c)
    for x in range(40, 130, 5):
        t = (x - 36) / 98
        top = 62 - int(14 * math.sin(math.pi * t) ** 0.8)
        for k in range(5):
            cv.put(x + k // 2, top - 2 + k // 2, (28, 72, 54))
            cv.put(x, top - 3, (28, 72, 54))
    for x in range(36, 134):
        for y in range(66, 70):
            cv.put(x, y, mix(cv.get(x, 65 - (y - 66)), (30, 40, 80), 0.5), tint=False)
    ground(cv, 88, (72, 100, 70), seed=5)
    pine(cv, 138, 104, 52, needle=(36, 74, 64))
    pine(cv, 14, 106, 34, needle=(36, 74, 64))
    for k in range(10):
        cv.put(78 + k, 84, (236, 232, 224))
        cv.put(80 + k // 2, 83, (200, 74, 60) if k < 6 else (236, 232, 224))
    return cv


def otaru():
    cv = Canvas("evening")
    sky(cv, 40)
    cloud(cv, 120, 12, 6)
    stone, stone_dark, roof = (150, 108, 84), (112, 78, 62), (66, 62, 72)
    bx = 0
    for i, w in enumerate((30, 26, 34, 28, 30, 26)):
        h = 24 + int(noise(i, 1, 4) * 8)
        top = 70 - h
        rect(cv, bx, top, bx + w, 70, stone)
        for y in range(top, 70):
            for x in range(bx, bx + w):
                if noise(x // 3, y // 2, 5) > 0.78:
                    cv.put(x, y, stone_dark)
        for k in range(8):
            for x in range(bx - 1 + k, bx + w + 1 - k):
                cv.put(x, top - k, roof if k < 7 else mix(roof, (255, 255, 255), 0.2))
        rect(cv, bx + w // 2 - 4, top - 10, bx + w // 2 + 4, top - 7, stone_dark)
        for wy in range(top + 6, 66, 10):
            for wx in range(bx + 5, bx + w - 4, 9):
                rect(cv, wx, wy, wx + 3, wy + 5, (44, 40, 54))
                cv.put(wx + 1, wy - 1, (44, 40, 54))
                cv.put(wx + 1, wy + 1, (255, 206, 120), tint=False)
        for x in range(bx + 2, bx + w - 2, 3):
            cv.put(x, 69, stone_dark)
        bx += w
    for x in range(W):
        cv.put(x, 70, (176, 168, 156))
        cv.put(x, 71, (120, 112, 104))
    water(cv, 72, 92, (46, 70, 120), glints=False)
    for lx in (26, 80, 134):
        for y in range(72, 92):
            cv.put(lx + int(math.sin(y * 1.3)), y, mix(cv.get(lx, y), (255, 214, 130), 0.5), tint=False)
    for y in range(92, H):
        for x in range(W):
            c = (150, 144, 134) if noise((x + (y // 3) * 2) // 5, y // 3, 4) > 0.5 else (130, 124, 116)
            cv.put(x, y, (96, 92, 86) if y % 3 == 0 or (x + (y // 3) * 2) % 5 == 0 else c)
    for lx in (26, 80, 134):
        for y in range(70, 92):
            cv.put(lx, y, (36, 36, 44), tint=False)
        for dx, dy in ((-1, -3), (0, -3), (1, -3), (-1, -2), (1, -2), (0, -4)):
            cv.put(lx + dx, 70 + dy, (255, 232, 160), tint=False)
        for dx in range(-3, 4):
            cv.put(lx + dx, 72, mix(cv.get(lx + dx, 72), (255, 214, 130), 0.4), tint=False)
    return cv


def sapporo():
    cv = Canvas("morning")
    sky(cv, 64)
    cloud(cv, 30, 16, 6)
    cloud(cv, 128, 22, 5)
    for x in range(W):
        top = 56 + int(3 * math.sin(x * 0.07) + 2 * math.sin(x * 0.23))
        for y in range(top, 70):
            cv.put(x, y, (226, 234, 244) if noise(x, y, 2) > 0.1 else (200, 214, 232))
    for y in range(64, H):
        for x in range(W):
            r = noise(x, y, 8)
            cv.put(x, y, (246, 250, 255) if r > 0.12 else (206, 220, 238))
    white, white_dark, red, red_dark, win = (246, 244, 236), (212, 208, 198), (184, 58, 50), (140, 40, 40), (70, 92, 122)
    rect(cv, 34, 56, 126, 84, white)
    for y in range(56, 84):
        if y % 3 == 0:
            rect(cv, 34, y, 126, y + 1, white_dark)
    for k in range(10):
        for x in range(32 + k, 128 - k):
            cv.put(x, 56 - k, red if (x + k) % 6 else red_dark)
    rect(cv, 66, 24, 94, 56, white)
    for y in range(24, 56):
        if y % 3 == 0:
            rect(cv, 66, y, 94, y + 1, white_dark)
    for k in range(9):
        for x in range(64 + k, 96 - k):
            cv.put(x, 23 - k, red if (x + k) % 5 else red_dark)
    rect(cv, 79, 8, 81, 15, (206, 168, 80))
    rect(cv, 72, 29, 88, 45, (236, 236, 228))
    for y in range(29, 45):
        for x in range(72, 88):
            if math.hypot(x - 79.5, y - 36.5) > 8:
                cv.put(x, y, white)
    for a in range(12):
        cv.put(int(79.5 + 6.2 * math.cos(a * math.pi / 6)), int(36.5 + 6.2 * math.sin(a * math.pi / 6)), (60, 56, 56))
    for y in range(31, 37):
        cv.put(79, y, (40, 40, 44))
    for x in range(79, 84):
        cv.put(x, 36, (40, 40, 44))
    for wx in range(44, 120, 14):
        if 62 < wx < 96:
            continue
        for wy in (62, 73):
            rect(cv, wx, wy, wx + 5, wy + 7, win)
            rect(cv, wx + 2, wy, wx + 3, wy + 7, white)
    rect(cv, 74, 66, 86, 84, (116, 78, 56))
    rect(cv, 79, 66, 80, 84, (86, 56, 42))
    for x in range(30, 130):
        for y in range(84, 88):
            if noise(x, y, 6) > 0.2 + (y - 84) * 0.1:
                cv.put(x, y, (250, 252, 255))
    pine(cv, 14, 98, 46, needle=(40, 84, 70))
    pine(cv, 148, 100, 40, flip=True, needle=(40, 84, 70))
    for tx in (14, 148):
        for y in range(60, 98):
            for x in range(tx - 12, tx + 13):
                if cv.get(x, y)[1] > cv.get(x, y)[0] + 20 and noise(x, y, 14) > 0.5 and (x + y) % 2 == 0:
                    cv.put(x, y, (250, 252, 255), tint=False)
    snowfall(cv, 70, 5)
    return cv


def furano():
    cv = Canvas("day")
    sky(cv, 52)
    cloud(cv, 30, 14, 6)
    cloud(cv, 124, 22, 7)

    def range_top(x):
        return 40 - 12 * max(0.0, 1 - abs(x - 100) / 56) ** 0.8 - 5 * abs(math.sin(x * 0.2)) - 3 * math.sin(x * 0.05)

    def snowy(x, y, depth):
        if depth < 5:
            return (246, 248, 252) if x < 110 else (214, 224, 238)
        return (102, 120, 156) if noise(x // 2, y // 2, 4) > 0.2 else (84, 100, 138)

    profile(cv, range_top, 56, snowy)
    for x in range(W):
        top = 50 + int(3 * math.sin(x * 0.07 + 1) + 2 * math.sin(x * 0.19))
        for y in range(top, 58):
            cv.put(x, y, (62, 120, 84) if noise(x // 2, y // 2, 3) > 0.2 else (46, 98, 70))
    rect(cv, 0, 56, W, 66, (62, 120, 84))
    for y in range(56, H):
        for x in range(W):
            top = 58 + int(5 * math.sin(x * 0.045 + 0.4) + 3 * math.sin(x * 0.13))
            if y < top:
                continue
            u = (x - 80) / max(1, y - 32)
            stripe = u * 16
            frac = stripe - math.floor(stripe)
            if y < 78:
                lav = [(150, 100, 200), (176, 128, 222), (122, 78, 176)]
                c = lav[int(math.floor(stripe)) % 3] if frac > 0.28 else (86, 130, 74)
            elif y < 90:
                band = (y - 78) // 3
                c = [(244, 196, 64), (230, 110, 60), (250, 246, 240), (214, 70, 110)][band % 4]
                if noise(x, y, 5) > 0.82:
                    c = mix(c, (255, 255, 255), 0.4)
            else:
                lav = [(160, 108, 210), (186, 138, 230), (128, 82, 184)]
                c = lav[int(math.floor(stripe)) % 3] if frac > 0.34 else (78, 124, 68)
            cv.put(x, y, c)
    for x in range(W):
        top = 58 + int(5 * math.sin(x * 0.045 + 0.4) + 3 * math.sin(x * 0.13))
        cv.put(x, top, (170, 214, 130))
    pine(cv, 24, 86, 28, needle=(44, 100, 72))
    pine(cv, 140, 92, 22, flip=True, needle=(44, 100, 72))
    rect(cv, 106, 82, 118, 88, (200, 74, 60))
    for k in range(6):
        for x in range(105 + k, 120 - k):
            cv.put(x, 81 - k, (70, 70, 84))
    return cv


def asahikawa():
    cv = Canvas("morning")
    sky(cv, 60)
    cloud(cv, 24, 12, 6)
    disc(cv, 130, 18, 6, (255, 244, 214), glow=(255, 226, 190))

    def back(x):
        return 44 - 16 * max(0.0, 1 - abs(x - 120) / 70) ** 0.8 - 5 * abs(math.sin(x * 0.3)) - 2 * math.sin(x * 0.07)

    def front(x):
        return 54 - 26 * max(0.0, 1 - abs(x - 52) / 62) ** 0.9 - 4 * abs(math.sin(x * 0.25 + 1)) + 4 * math.sin(x * 0.05)

    def white(shadow_x):
        def color(x, y, depth):
            lit = x < shadow_x
            if depth < 2:
                return (255, 255, 255)
            if noise(x // 2, y, 4) > 0.82 and depth > 4:
                return (92, 116, 156) if lit else (70, 92, 132)
            return (236, 244, 252) if lit else (190, 206, 230)

        return color

    profile(cv, back, 62, white(150))
    profile(cv, front, 66, white(60))
    for x in range(W):
        top = 62 + int(2 * math.sin(x * 0.2))
        for y in range(top, 70):
            cv.put(x, y, (52, 96, 82) if noise(x, y, 6) > 0.2 else (40, 80, 70))
    for y in range(70, H):
        for x in range(W):
            r = noise(x, y, 9)
            cv.put(x, y, (248, 251, 255) if r > 0.1 else (208, 222, 240))
    for y in range(80, 94):
        for x in range(W):
            edge = abs((y - 80) - 7 - 3 * math.sin(x * 0.06))
            if edge < 4.5:
                cv.put(x, y, (120, 168, 204) if edge < 3.4 and noise(x // 3, y, 2) > 0.3 else (200, 224, 240))
    for x in range(30, 130):
        y = 78 - int(8 * math.sin((x - 30) / 100 * math.pi))
        cv.put(x, y, (96, 106, 126))
        cv.put(x, y + 1, (70, 78, 98))
    for x in range(30, 131, 10):
        y = 78 - int(8 * math.sin((x - 30) / 100 * math.pi))
        for k in range(y + 2, 92):
            cv.put(x, k, (70, 78, 98))
    pine(cv, 22, 106, 44, needle=(40, 84, 70))
    pine(cv, 140, 104, 38, flip=True, needle=(40, 84, 70))
    pine(cv, 106, 98, 26, needle=(40, 84, 70))
    for tx in (22, 140, 106):
        for y in range(56, 106):
            for x in range(tx - 12, tx + 13):
                c = cv.get(x, y)
                if c[1] > c[0] + 14 and noise(x, y, 14) > 0.45 and (x + y) % 2 == 0:
                    cv.put(x, y, (250, 252, 255), tint=False)
    snowfall(cv, 30, 7)
    return cv


SCENES = {
    "hakodate": hakodate,
    "onuma": onuma,
    "toyako": toyako,
    "otaru": otaru,
    "sapporo": sapporo,
    "furano": furano,
    "asahikawa": asahikawa,
}
