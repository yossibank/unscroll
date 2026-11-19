from artlib.trip_kit import Layer, W, dirt, grass, noise, pine, ridge, shade

GLYPHS = {
    "お": ("..#..#.", "#####..", "..#.##.", ".#####.", "#.#..#.", "#.#..#.", ".##.##."),
    "る": (".#####.", ".....#.", "...###.", "..#..#.", ".#.#.#.", ".#..##.", "..###.."),
    "す": ("#######", "...#...", "..###..", ".#.#.#.", "..###..", "...#...", "..#.#.."),
}


def rect(layer, x0, y0, x1, y1, c):
    for y in range(y0, y1):
        for x in range(x0, x1):
            layer.put(x, y, c)


def glyph(layer, ch, x0, y0, c):
    for j, row in enumerate(GLYPHS[ch]):
        for i, v in enumerate(row):
            if v == "#":
                rect(layer, x0 + i * 2, y0 + j * 2, x0 + i * 2 + 2, y0 + j * 2 + 2, c)


def station(layer, cx, base):
    wall, wall_dark = (176, 128, 84), (140, 98, 64)
    rect(layer, cx - 44, base - 40, cx + 44, base, wall)
    for x in range(cx - 44, cx + 44, 4):
        rect(layer, x, base - 40, x + 1, base, wall_dark)
    roof, roof_light, roof_dark = (94, 104, 120), (130, 142, 158), (60, 66, 80)
    for k in range(16):
        half = 54 - k * 3
        for x in range(cx - half, cx + half + 1):
            c = roof_light if k == 0 else roof_dark if (x + k) % 4 == 0 else roof
            layer.put(x, base - 40 - k, c)
    rect(layer, cx - 56, base - 40, cx + 57, base - 37, roof_dark)
    frame = (74, 52, 40)
    rect(layer, cx - 29, base - 35, cx + 30, base - 17, frame)
    rect(layer, cx - 28, base - 34, cx + 29, base - 18, (244, 238, 222))
    for i, ch in enumerate("おるす"):
        glyph(layer, ch, cx - 26 + i * 18, base - 33, (52, 44, 40))
    rect(layer, cx - 8, base - 14, cx + 9, base, (96, 64, 44))
    rect(layer, cx, base - 14, cx + 1, base, (74, 48, 34))
    for x in (cx - 40, cx + 22):
        rect(layer, x, base - 14, x + 18, base - 3, (62, 52, 48))
        rect(layer, x + 1, base - 13, x + 17, base - 4, (196, 226, 240))
        rect(layer, x + 8, base - 13, x + 10, base - 4, (62, 52, 48))
    rect(layer, cx + 62, base - 34, cx + 65, base, (74, 68, 72))
    rect(layer, cx + 58, base - 40, cx + 69, base - 34, (74, 68, 72))
    rect(layer, cx + 59, base - 39, cx + 68, base - 35, (255, 240, 176))


def platform(layer, top, bottom):
    rect(layer, 0, top, W, bottom, (190, 184, 172))
    rect(layer, 0, top, W, top + 2, (226, 220, 206))
    for x in range(W):
        layer.put(x, bottom - 1, (150, 144, 132))
        if x % 12 < 6:
            layer.put(x, top + 4, (236, 200, 72))


def flowers(layer, top, bottom, seed):
    for y in range(top, bottom, 3):
        for x in range(0, W, 5):
            r = noise(x, y, seed)
            if r > 0.86:
                c = (255, 236, 120) if r > 0.95 else (250, 190, 206)
                layer.put(x, y, c)
                layer.put(x + 1, y, shade(c, 0.86))


def orusueki():
    far, mid, near = Layer(), Layer(), Layer()
    ridge(far, 116, ((10, 1, 0.3), (5, 4, 1.4), (2, 9, 0.2)), (132, 170, 140), 150, haze=0.3)
    ridge(far, 134, ((6, 2, 0.9), (2, 7, 0.4)), (110, 156, 112), 150, haze=0.1)
    grass(mid, 140, 160, (110, 156, 100))
    for x in (24, 290):
        pine(mid, x, 152, 40)
    station(mid, 180, 160)
    platform(mid, 160, 168)
    dirt(near, 168, 186, (212, 196, 160))
    grass(near, 186, 210, (96, 146, 84))
    flowers(near, 190, 210, 11)
    for x in (60, 250):
        pine(near, x, 206, 52)
    return far, mid, near


SCENES = {
    "orusueki": orusueki,
}
