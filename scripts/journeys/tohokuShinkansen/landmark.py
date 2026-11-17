import math
from artlib.landmark_kit import Canvas, H, W, cloud, disc, draw, forest_color, fuji, ground, mix, moon, noise, pine, profile, reflect, shade, sky, water


def rect(cv, x0, y0, x1, y1, c, tint=True):
    for y in range(y0, y1):
        for x in range(x0, x1):
            cv.put(x, y, c, tint=tint)


def viaduct(cv, y, canopy=None):
    rect(cv, 0, y, W, y + 3, (170, 170, 168))
    rect(cv, 0, y + 3, W, y + 4, (120, 120, 120))
    for x in range(6, W, 22):
        rect(cv, x, y + 4, x + 4, y + 16, (150, 150, 148))
    if canopy:
        x0, x1 = canopy
        rect(cv, x0, y - 17, x1, y - 15, (92, 100, 112))
        for x in range(x0 + 2, x1, 14):
            rect(cv, x, y - 15, x + 1, y, (92, 100, 112))


def train(cv, x0, x1, y):
    body, green, pink, glass = (244, 246, 248), (44, 150, 116), (232, 124, 156), (60, 84, 112)
    rect(cv, x0, y - 9, x1, y - 1, body)
    rect(cv, x0, y - 4, x1, y - 2, green)
    rect(cv, x0, y - 2, x1, y - 1, pink)
    rect(cv, x0, y - 1, x1, y, (96, 100, 108))
    for x in range(x0 + 3, x1 - 2, 5):
        rect(cv, x, y - 7, x + 3, y - 5, glass)
    for i in range(9):
        top = y - 9 + int(i * i / 9)
        rect(cv, x1 + i, top, x1 + i + 1, y - 1, body)
        if top < y - 4:
            cv.put(x1 + i, y - 4, green)
    rect(cv, x1 + 1, y - 7, x1 + 4, y - 5, glass)


def tokyoeki():
    cv = Canvas("morning")
    sky(cv, 70)
    cloud(cv, 120, 14, 7)
    cloud(cv, 30, 24, 5)
    for i, x in enumerate(range(0, W, 14)):
        h = 22 + int(noise(i, 0, 4) * 24)
        glass = (110, 140, 176) if i % 2 else (138, 164, 196)
        rect(cv, x, 62 - h, x + 13, 70, glass)
        for y in range(62 - h + 3, 68, 4):
            for xx in range(x + 2, x + 12, 3):
                cv.put(xx, y, shade(glass, 0.78))
    brick, brick_dark, stone, roof, win = (178, 78, 58), (146, 58, 46), (238, 230, 212), (92, 120, 116), (56, 62, 84)
    rect(cv, 8, 48, 152, 74, brick)
    for y in range(48, 74):
        for x in range(8, 152):
            if (y % 3 == 0 and x % 5 == (y // 3) % 2) or noise(x, y, 4) > 0.93:
                cv.put(x, y, brick_dark)
    for y in (46, 47, 56, 57, 66, 67):
        rect(cv, 8, y, 152, y + 1, stone)
    rect(cv, 8, 73, 152, 74, shade(stone, 0.8))
    for x in range(14, 148, 6):
        if 70 < x < 90:
            continue
        for y in (51, 60, 69):
            rect(cv, x, y - 3 if y < 69 else y - 4, x + 3, y, win)
            cv.put(x + 1, y - 4 if y < 69 else y - 5, stone)
    for cx in (24, 136):
        rect(cv, cx - 11, 38, cx + 12, 48, brick)
        rect(cv, cx - 12, 37, cx + 13, 38, stone)
        for y in range(25, 37):
            t = (36 - y) / 11
            hw = int(10 * math.sqrt(max(0.0, 1 - t * t * 0.9)))
            for x in range(cx - hw, cx + hw + 1):
                cv.put(x, y, roof if (x + y) % 4 else shade(roof, 0.8))
        rect(cv, cx - 10, 36, cx + 11, 37, (66, 88, 86))
        rect(cv, cx, 18, cx + 1, 25, (230, 196, 90))
        rect(cv, cx - 3, 40, cx - 1, 45, win)
        rect(cv, cx + 3, 40, cx + 5, 45, win)
    for i in range(7):
        rect(cv, 66 + i, 38 + i, 94 - i, 39 + i, roof)
    rect(cv, 68, 45, 92, 48, stone)
    rect(cv, 70, 48, 90, 74, (232, 222, 200))
    for x in range(72, 90, 5):
        rect(cv, x, 50, x + 3, 72, shade(brick, 1.0))
        rect(cv, x, 50, x + 3, 53, win)
    for y in range(74, H):
        for x in range(W):
            tile = (x // 8 + y // 5) % 2
            c = (206, 200, 190) if tile else (190, 184, 174)
            if y == 74:
                c = (150, 144, 136)
            cv.put(x, y, c)
    for x in (4, 40, 120, 156):
        rect(cv, x, 78, x + 2, 96, (96, 70, 52))
        for y in range(62, 84):
            for xx in range(x - 9, x + 11):
                if ((xx - x - 1) / 10) ** 2 + ((y - 72) / 11) ** 2 < 1 + 0.2 * noise(xx, y, 8) - 0.2:
                    cv.put(xx, y, (232, 196, 70) if noise(xx // 2, y // 2, x) > 0.4 else (206, 160, 52))
    return cv


def utsunomiya():
    cv = Canvas("day")
    sky(cv, 54)
    cloud(cv, 30, 12, 6)
    cloud(cv, 126, 20, 5)
    profile(cv, lambda x: 40 + 8 * math.sin(x * 0.03 + 1), 56, forest_color((96, 126, 150), False), 0, W)
    fuji(cv, 44, 16, 56, 42, 3, rock=(100, 130, 118), haze=0.2)
    stone, stone_dark, stone_light = (190, 174, 136), (150, 134, 102), (216, 202, 166)
    for y in range(34, 62):
        for x in range(96, W):
            edge = 96 + int(10 * (1 - (y - 34) / 28) * (1 + math.sin(y * 0.5)) * 0.4)
            if x < edge:
                continue
            c = stone
            if (y - 34) % 5 == 0:
                c = stone_dark
            elif (x + ((y - 34) // 5) * 7) % 13 == 0:
                c = stone_dark
            elif noise(x, y, 5) > 0.92:
                c = stone_light
            cv.put(x, y, c)
    for x in range(116, 150, 14):
        rect(cv, x, 44, x + 8, 52, (64, 56, 46))
        rect(cv, x, 44, x + 8, 45, stone_light)
    rect(cv, 96, 33, W, 34, (92, 130, 80))
    viaduct(cv, 62, canopy=(8, 74))
    train(cv, 20, 86, 62)
    for y in range(80, H):
        row = (y - 80) // 6
        for x in range(W):
            if (y - 80) % 6 == 0:
                c = (150, 132, 92)
            elif row % 2:
                c = (150, 196, 210) if noise(x // 5, y, 2) > 0.74 else (122, 172, 92)
            else:
                c = (96, 150, 76) if (x + y) % 3 else (124, 176, 92)
            cv.put(x, y, c)
    rect(cv, 0, 78, W, 80, (120, 110, 90))
    pine(cv, 148, 98, 30, needle=(46, 96, 72))
    return cv


def sendai():
    cv = Canvas("evening")
    sky(cv, 66)
    disc(cv, 120, 56, 7, (255, 206, 130), glow=(255, 180, 120))
    cloud(cv, 40, 18, 6)
    for x in range(W):
        h = int(8 + 14 * noise(x // 9, 0, 8))
        rect(cv, x, 66 - h, x + 1, 68, (92, 72, 108))
    for x in (30, 100):
        rect(cv, x, 40, x + 6, 68, (80, 62, 98))
        rect(cv, x + 2, 32, x + 3, 40, (80, 62, 98))
    for y in range(68, H):
        t = (y - 68) / 32
        half = 3 + t * 52
        for x in range(W):
            if abs(x - 80) <= half:
                c = (118, 108, 118) if noise(x, y, 6) > 0.12 else (100, 92, 102)
                if abs(x - 80) <= 0.4 + t * 0.6 and y % 4 < 2:
                    c = (236, 214, 170)
            else:
                c = (96, 128, 84) if noise(x, y, 3) > 0.15 else (80, 110, 72)
            cv.put(x, y, c)
    trunk = (92, 68, 54)
    for side in (-1, 1):
        for k, base in enumerate((74, 80, 90, 104)):
            t = (base - 68) / 32
            x = 80 + side * (6 + t * 58)
            r = 5 + t * 15
            rect(cv, int(x) - 1, int(base - r * 1.3), int(x) + 2, base, trunk)
            cy = base - r * 1.6
            for y in range(int(cy - r), int(cy + r)):
                for xx in range(int(x - r - 2), int(x + r + 3)):
                    if ((xx - x) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 <= 1 + 0.2 * noise(xx, y, 6):
                        n = noise(xx // 2, y // 2, k + side * 5)
                        cv.put(xx, y, (62, 114, 62) if n < 0.5 else (94, 146, 70) if n < 0.85 else (170, 160, 70))
    rect(cv, 0, 20, 1, 21, (80, 70, 70))
    colors = [(246, 120, 150), (255, 220, 90), (110, 190, 230), (130, 210, 130), (250, 250, 250)]
    for x in range(4, W - 4, 7):
        sag = int(4 * math.sin(math.pi * x / W))
        top = 16 + sag
        cv.put(x, top - 1, (60, 50, 60))
        length = 10 + int(noise(x, 1, 3) * 9)
        for i in range(length):
            cv.put(x, top + i, colors[(x // 7) % 5], tint=False)
            cv.put(x + 1, top + i, mix(colors[(x // 7) % 5], (255, 255, 255), 0.3), tint=False)
        for dx in range(-1, 3):
            cv.put(x + dx, top - 2, colors[(x // 7 + 2) % 5], tint=False)
    return cv


def morioka():
    cv = Canvas("day")
    sky(cv, 62)
    cloud(cv, 24, 14, 6)
    cloud(cv, 134, 26, 5)
    fuji(cv, 98, 14, 62, 74, 14, rock=(100, 128, 124), haze=0.12)
    profile(cv, lambda x: 56 - 3 * math.sin(x * 0.07), 64, forest_color((70, 114, 80)), 0, W)
    water(cv, 64, 92, (52, 108, 140))
    truss = (84, 94, 110)
    for x in range(0, W):
        rect(cv, x, 70, x + 1, 72, truss)
        if x % 16 < 1:
            for y in range(58, 70):
                cv.put(x, y, truss)
        top = 58 + int(5 * (1 - math.cos((x % 16) / 16 * math.tau)) / 2 * 0)
        cv.put(x, top, truss)
    for x in range(0, W, 16):
        for k in range(12):
            cv.put(x + k, 70 - k, truss)
            cv.put(x + 16 - k if k < 12 else x, 70 - k, truss)
    for x in range(12, W, 48):
        rect(cv, x, 72, x + 6, 92, (150, 146, 138))
    viaduct(cv, 60, canopy=None)
    train(cv, 40, 100, 60)
    for y in range(92, H):
        for x in range(W):
            cv.put(x, y, (112, 156, 84) if y == 92 else (92, 136, 72) if noise(x, y, 3) > 0.15 else (76, 118, 62))
    for x in (14, 132):
        pine(cv, x, 98, 34, needle=(46, 96, 72))
    return cv


def hachinohe():
    cv = Canvas("morning")
    sky(cv, 52)
    cloud(cv, 30, 14, 6)
    disc(cv, 116, 50, 6, (255, 224, 164), glow=(255, 200, 150))
    water(cv, 52, 88, (44, 96, 148))
    for x in range(W):
        rect(cv, x, 52, x + 1, 53, (255, 220, 170), tint=False) if abs(x - 116) < 14 and x % 2 == 0 else None
    for y in range(54, 88, 3):
        half = 3 + (y - 52) * 0.2
        for x in range(int(116 - half), int(116 + half)):
            if noise(x, y, 2) > 0.3:
                cv.put(x, y, mix(cv.get(x, y), (255, 214, 160), 0.6), tint=False)
    rect(cv, 96, 62, W, 66, (150, 154, 160))
    rect(cv, 96, 62, W, 63, (190, 194, 198))
    rect(cv, 140, 44, 146, 62, (246, 246, 244))
    rect(cv, 139, 40, 147, 44, (214, 62, 50))
    rect(cv, 141, 36, 145, 40, (60, 64, 72))
    rect(cv, 142, 33, 144, 36, (230, 196, 90))
    for bx, by, s in ((16, 74, 1), (60, 80, 1), (98, 72, 0)):
        w = 22 if s else 16
        for i in range(5):
            rect(cv, bx + i, by + i, bx + w - i, by + i + 1, (58, 70, 96) if i else (230, 230, 226))
        rect(cv, bx + 5, by - 8, bx + 11, by, (240, 236, 224))
        rect(cv, bx + 5, by - 8, bx + 11, by - 7, (214, 62, 50))
        rect(cv, bx + w - 5, by - 14, bx + w - 4, by, (84, 66, 52))
        reflect(cv, {(x, y): cv.get(x, y) for x in range(bx, bx + w) for y in range(by - 8, by + 1)}, by + 1, by + 1, 88, (44, 96, 148), 0.3)
    for gx, gy in ((30, 36), (44, 30), (122, 24), (70, 42)):
        cv.put(gx, gy, (250, 250, 250), tint=False)
        cv.put(gx + 1, gy - 1, (250, 250, 250), tint=False)
        cv.put(gx + 2, gy - 1, (250, 250, 250), tint=False)
        cv.put(gx + 3, gy, (250, 250, 250), tint=False)
    for y in range(88, H):
        for x in range(W):
            c = (150, 150, 152) if y == 88 else (170, 168, 164) if noise(x, y, 3) > 0.15 else (150, 148, 146)
            cv.put(x, y, c)
    for i, x in enumerate(range(12, W, 38)):
        col = ((60, 124, 190), (232, 142, 54), (84, 160, 120))[i % 3]
        rect(cv, x, 92, x + 14, 100, col)
        rect(cv, x, 92, x + 14, 94, shade(col, 1.25))
        rect(cv, x, 97, x + 14, 98, shade(col, 0.8))
    return cv


def shinaomori():
    cv = Canvas("night")
    sky(cv, 68)
    moon(cv, 126, 18)
    profile(cv, lambda x: 36 + 22 * (1 - abs(((x * 0.5) % 40) - 20) / 20) * 0.6 + 8 * math.sin(x * 0.04), 70,
            lambda x, y, d: (210, 224, 244) if d < 5 else (70, 88, 126))
    for y in range(70, H):
        for x in range(W):
            r = noise(x, y, 6)
            cv.put(x, y, (226, 236, 252) if y == 70 else (150, 170, 208) if r < 0.12 else (186, 204, 232), tint=False)
    rect(cv, 6, 58, 40, 70, (210, 214, 224))
    rect(cv, 4, 55, 42, 58, (96, 108, 130))
    for x in range(9, 38, 5):
        rect(cv, x, 61, x + 3, 66, (255, 226, 150), tint=False)
    cx = 94
    for y in range(26, 66):
        t = (y - 26) / 40
        hw = int(8 + 26 * math.sin(t * math.pi / 2) ** 0.8)
        for x in range(cx - hw, cx + hw + 1):
            d = abs(x - cx) / max(1, hw)
            n = noise(x // 3, y // 3, 5)
            c = (255, 214, 90) if d < 0.35 else (240, 120, 50) if n > 0.45 else (214, 54, 44)
            if (x - cx) % 6 == 0 or (y - 26) % 9 == 0:
                c = (60, 30, 30)
            cv.put(x, y, c, tint=False)
    for dx in (-18, 18):
        for y in range(40, 60):
            for x in range(cx + dx - 4, cx + dx + 5):
                cv.put(x, y, (255, 190, 70) if (y - 40) % 8 else (60, 30, 30), tint=False)
    rect(cv, cx - 38, 66, cx + 39, 72, (66, 44, 40))
    rect(cv, cx - 38, 66, cx + 39, 67, (150, 100, 70))
    for wx in (cx - 28, cx + 28):
        for y in range(70, 76):
            for x in range(wx - 3, wx + 4):
                if (x - wx) ** 2 + (y - 73) ** 2 <= 9:
                    cv.put(x, y, (50, 40, 40))
    for x in range(0, W, 5):
        sag = int(5 * math.sin(math.pi * (x % 40) / 40))
        cv.put(x, 8 + sag, (80, 60, 60))
        if x % 20 == 0:
            for dy in range(0, 5):
                for dx in range(-2, 3):
                    if dx * dx + (dy - 2) ** 2 <= 5:
                        cv.put(x + dx, 9 + sag + dy, (255, 120, 60) if dy % 2 else (255, 196, 90), tint=False)
    for x, base in ((134, 92), (150, 86), (122, 98)):
        pine(cv, x, base, 34, needle=(36, 72, 60))
        for y in range(base - 34, base - 10):
            for xx in range(x - 9, x + 10):
                if cv.px[y][xx] != (0, 0, 0) and noise(xx, y, 9) > 0.55 and (xx + y) % 2 == 0 and 0 <= xx < W:
                    cv.put(xx, y, (232, 240, 250))
    for n in range(70):
        x, y = int(noise(n, 3, 7) * W), int(noise(n, 4, 7) * H)
        cv.put(x, y, (250, 252, 255), tint=False)
        if n % 3 == 0:
            cv.put(x + 1, y, (210, 226, 248), tint=False)
    return cv


SCENES = {
    "tokyoeki": tokyoeki,
    "utsunomiya": utsunomiya,
    "sendai": sendai,
    "morioka": morioka,
    "hachinohe": hachinohe,
    "shinaomori": shinaomori,
}
