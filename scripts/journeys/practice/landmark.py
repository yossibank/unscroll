from artlib.landmark_kit import Canvas, H, W, cloud, mix, noise, pine, shade, sky

GLYPHS = {
    "お": ("..#..#.", "#####..", "..#.##.", ".#####.", "#.#..#.", "#.#..#.", ".##.##."),
    "る": (".#####.", ".....#.", "...###.", "..#..#.", ".#.#.#.", ".#..##.", "..###.."),
    "す": ("#######", "...#...", "..###..", ".#.#.#.", "..###..", "...#...", "..#.#.."),
}


def rect(cv, x0, y0, x1, y1, c, tint=True):
    for y in range(y0, y1):
        for x in range(x0, x1):
            cv.put(x, y, c, tint=tint)


def glyph(cv, ch, x0, y0, c):
    for j, row in enumerate(GLYPHS[ch]):
        for i, v in enumerate(row):
            if v == "#":
                rect(cv, x0 + i * 2, y0 + j * 2, x0 + i * 2 + 2, y0 + j * 2 + 2, c)


def orusueki():
    cv = Canvas("day")
    sky(cv, 62)
    cloud(cv, 30, 12, 6)
    cloud(cv, 126, 20, 5)
    for x in range(W):
        top = 54 - int(6 * abs(((x + 20) % 80) / 40 - 1))
        for y in range(top, 64):
            cv.put(x, y, (120, 164, 130) if noise(x // 2, y, 3) > 0.2 else (96, 144, 112))
    for y in range(64, 72):
        for x in range(W):
            cv.put(x, y, (110, 156, 100) if noise(x, y, 4) > 0.2 else (90, 136, 88))
    pine(cv, 140, 66, 30, flip=True)
    pine(cv, 150, 66, 22)
    wall, wall_dark = (176, 128, 84), (140, 98, 64)
    rect(cv, 26, 40, 98, 72, wall)
    for x in range(26, 98, 4):
        rect(cv, x, 40, x + 1, 72, wall_dark)
    roof, roof_light, roof_dark = (94, 104, 120), (130, 142, 158), (60, 66, 80)
    for k in range(14):
        half = 44 - k * 3
        for x in range(62 - half, 62 + half + 1):
            c = roof_light if k == 0 else roof_dark if (x + k) % 4 == 0 else roof
            cv.put(x, 40 - k, c)
    for k in range(3):
        rect(cv, 16 + k, 40 - k // 2, 108 - k, 42, roof)
    rect(cv, 16, 41, 108, 43, roof_dark)
    rect(cv, 36, 44, 88, 60, (244, 238, 222))
    rect(cv, 35, 43, 89, 44, (74, 52, 40))
    rect(cv, 35, 60, 89, 61, (74, 52, 40))
    rect(cv, 35, 43, 36, 61, (74, 52, 40))
    rect(cv, 88, 43, 89, 61, (74, 52, 40))
    for i, ch in enumerate("おるす"):
        glyph(cv, ch, 38 + i * 17, 46, (52, 44, 40))
    rect(cv, 55, 62, 69, 72, (96, 64, 44))
    rect(cv, 61, 62, 63, 72, (74, 48, 34))
    for x in (30, 78):
        rect(cv, x, 62, x + 14, 71, (62, 52, 48))
        rect(cv, x + 1, 63, x + 13, 70, (196, 226, 240))
        rect(cv, x + 6, 63, x + 8, 70, (62, 52, 48))
    rect(cv, 0, 72, W, 80, (190, 184, 172))
    rect(cv, 0, 72, W, 74, (226, 220, 206))
    for x in range(W):
        cv.put(x, 79, (150, 144, 132))
        if x % 12 < 6:
            cv.put(x, 77, (236, 200, 72))
    for y in range(80, H):
        for x in range(W):
            r = noise(x, y, 8)
            cv.put(x, y, (132, 118, 104) if r > 0.2 else (108, 96, 84))
    for x in range(0, W, 12):
        rect(cv, x, 88, x + 7, 92, (96, 66, 48))
    rect(cv, 0, 85, W, 87, (186, 192, 204))
    rect(cv, 0, 93, W, 95, (186, 192, 204))
    wood, wood_dark = (186, 132, 84), (128, 88, 56)
    rect(cv, 108, 62, 140, 65, wood)
    rect(cv, 108, 56, 140, 59, wood)
    rect(cv, 108, 59, 140, 62, wood_dark)
    for x in (110, 136):
        rect(cv, x, 65, x + 3, 74, wood_dark)
        rect(cv, x, 56, x + 3, 62, wood_dark)
    rect(cv, 8, 46, 11, 74, (74, 68, 72))
    rect(cv, 4, 42, 15, 46, (74, 68, 72))
    rect(cv, 5, 43, 14, 46, (255, 240, 176), tint=False)
    return cv


SCENES = {
    "orusueki": orusueki,
}
