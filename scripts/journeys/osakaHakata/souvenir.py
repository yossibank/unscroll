import math
from artlib.souvenir_kit import OUT, Sprite, ellipsoid, noise, pillow, steam


def solid(s, x, y):
    return s.get(x, y) not in (None, OUT)


def bowl(s, ramp, cx, cy, rx, ry, rim_y):
    body = ellipsoid(cx, cy, rx, ry, taper=0.1)
    s.shape(lambda x, y: body(x, y) if y >= rim_y else None, ramp, spec=(255, 255, 255), power=20, border=True)


def ball(s, cx, cy, r, ramp, spec, power, seed):
    def tex(x, y, n):
        return -1 if noise(x, y, seed) < 0.1 else 0

    s.shape(ellipsoid(cx, cy, r, r), ramp, spec=spec, power=power, tex=tex, border=True)


def butaman():
    s = Sprite()
    bamboo = [(120, 84, 44), (158, 114, 62), (190, 146, 84), (214, 176, 112), (232, 200, 140)]
    tray = ellipsoid(24, 34, 22, 10, taper=0.05)
    s.shape(lambda x, y: tray(x, y) if y >= 32 else None, bamboo, border=True)
    for x in range(4, 45):
        for y in range(33, 43):
            if (x + y) % 4 == 0 and solid(s, x, y):
                s.put(x, y, bamboo[1])
    bun = [(190, 176, 158), (220, 208, 190), (240, 232, 218), (250, 246, 238), (255, 254, 250)]
    dome = ellipsoid(24, 28, 17, 17)
    s.shape(lambda x, y: dome(x, y) if y <= 33 else None, bun, spec=(255, 255, 255), power=16, border=True)
    for k in range(10):
        a = k / 10 * math.tau
        for i in range(1, 8):
            x = int(round(24 + math.cos(a + i * 0.12) * i * 0.8))
            y = int(round(16 + math.sin(a + i * 0.12) * i * 0.55))
            if solid(s, x, y):
                s.put(x, y, bun[1])
    s.put(24, 16, bun[0])
    steam(s, 14, 12, 9, 0.4)
    steam(s, 33, 11, 8, 2.0)
    return s.outline()


def akashiyaki():
    s = Sprite()
    wood = [(96, 62, 34), (130, 88, 48), (160, 114, 66), (188, 142, 88), (210, 170, 112)]
    board = pillow([(2, 28), (46, 28), (44, 42), (4, 42)], 4.0)
    s.shape(board, wood, border=True)
    for x in range(5, 44):
        if x % 7 == 0:
            for y in range(30, 41):
                s.put(x, y, wood[1])
    egg = [(150, 92, 30), (196, 134, 44), (226, 170, 66), (244, 202, 104), (252, 226, 150)]
    for cx, cy in ((12, 33), (24, 31), (36, 33), (18, 38), (30, 38)):
        ball(s, cx, cy, 6, egg, (255, 240, 200), 18, cx + cy)
    cup = [(150, 162, 176), (186, 196, 208), (214, 222, 230), (236, 240, 244), (252, 252, 254)]
    bowl(s, cup, 38, 17, 9, 8, 13)
    dashi = [(150, 104, 40), (180, 134, 58), (206, 164, 84), (224, 190, 112)]
    s.shape(ellipsoid(38, 14, 7, 3, depth=1.2), dashi, border=True)
    for dx in (-3, 0, 3):
        s.put(38 + dx, 14, (110, 160, 80))
    steam(s, 12, 24, 8, 0.2)
    steam(s, 26, 22, 8, 1.6)
    return s.outline()


def kibidango():
    s = Sprite()
    leaf = [(40, 92, 56), (60, 126, 70), (86, 156, 88), (120, 186, 110), (160, 208, 136)]
    blade = pillow([(2, 40), (24, 26), (46, 40), (24, 46)], 6.0)
    s.shape(blade, leaf, border=True)
    dough = [(178, 138, 72), (208, 170, 96), (230, 200, 128), (244, 224, 160), (252, 240, 196)]
    for cx, cy in ((14, 34), (24, 36), (34, 34), (19, 25), (29, 25), (24, 16)):
        ball(s, cx, cy, 7, dough, (255, 252, 230), 12, cx * 3 + cy)
        for k in range(5):
            x = cx - 3 + int(noise(cx, k, 9) * 7)
            y = cy - 3 + int(noise(cy, k, 8) * 7)
            if solid(s, x, y):
                s.put(x, y, (255, 250, 232))
    return s.outline()


def noodles(s, soup, y_range, seed):
    for k in range(7):
        for x in range(10 + k, 36 + k):
            y = y_range[0] + k % 3
            if solid(s, x, y) and noise(x, k, seed) > 0.4:
                s.put(x, y, soup)


def onomichi_ramen():
    s = Sprite()
    ceramic = [(150, 162, 176), (186, 196, 208), (214, 222, 230), (236, 240, 244), (252, 252, 254)]
    bowl(s, ceramic, 24, 24, 19, 18, 24)
    for x in range(8, 41):
        s.put(x, 30, (40, 70, 120) if x % 4 < 2 else (80, 112, 160))
    broth = [(120, 74, 36), (150, 96, 46), (178, 124, 64), (200, 150, 86)]
    s.shape(ellipsoid(24, 24, 18, 6, depth=1.5), broth, border=True)
    noodles(s, (240, 220, 160), (22, 25), 3)
    pork = [(120, 60, 50), (156, 92, 76), (196, 134, 108), (226, 172, 140)]
    for px, py in ((14, 24), (26, 22)):
        s.shape(ellipsoid(px, py, 7, 3, depth=1.5), pork, border=True)
        for dx in range(-4, 5):
            s.put(px + dx, py, (248, 232, 220) if dx % 3 == 0 else pork[3])
    for x in range(30, 40):
        s.put(x, 21 + (x % 2), (200, 160, 90))
    for x, y in ((20, 19), (22, 20), (28, 26), (17, 28), (33, 25)):
        s.put(x, y, (104, 170, 84))
    steam(s, 18, 15, 10, 0.0)
    steam(s, 29, 14, 9, 1.8)
    return s.outline()


def okonomiyaki():
    s = Sprite()
    iron = [(60, 62, 70), (88, 90, 100), (118, 120, 130), (150, 152, 162), (186, 188, 196)]
    plate = ellipsoid(24, 30, 22, 14, depth=2.0)
    s.shape(plate, iron, spec=(240, 240, 250), power=20, border=True)
    cake = [(88, 44, 24), (120, 66, 34), (152, 92, 46), (182, 122, 64), (206, 150, 84)]
    top = ellipsoid(24, 26, 19, 12, depth=6)

    def sauce(x, y, n):
        return -1 if noise(x, y, 41) < 0.12 else 0

    s.shape(top, cake, spec=(255, 226, 170), power=14, tex=sauce, border=True)
    for i in range(34):
        x = 8 + i
        y = 20 + int(round(3 * math.sin(i * 0.9))) + (i % 5) // 3
        for yy in (y, y + 1):
            if solid(s, x, yy):
                s.put(x, yy, (252, 244, 214))
    for x in range(8, 41):
        for y in range(15, 38):
            if not solid(s, x, y):
                continue
            r = noise(x, y, 33)
            if r > 0.95:
                s.put(x, y, (84, 150, 70))
            elif r < 0.03:
                s.put(x, y, (226, 168, 110))
    for k in range(10):
        s.put(36 + k // 2, 40 + k // 3, (214, 216, 226))
        s.put(37 + k // 2, 40 + k // 3, (170, 172, 184))
    steam(s, 17, 14, 8, 0.6)
    steam(s, 29, 13, 8, 2.3)
    return s.outline()


def hakata_ramen():
    s = Sprite()
    ceramic = [(170, 70, 54), (206, 96, 74), (230, 130, 104), (244, 170, 146), (252, 210, 196)]
    bowl(s, ceramic, 24, 24, 19, 18, 24)
    for x in range(8, 41):
        s.put(x, 30, (250, 244, 232) if x % 4 < 3 else (60, 50, 50))
    milk = [(214, 190, 150), (232, 212, 176), (244, 230, 200), (252, 242, 220)]
    s.shape(ellipsoid(24, 24, 18, 6, depth=1.5), milk, border=True)
    noodles(s, (250, 236, 196), (22, 25), 7)
    pork = [(130, 70, 56), (164, 100, 80), (204, 142, 114), (232, 180, 146)]
    s.shape(ellipsoid(15, 23, 6, 3, depth=1.5), pork, border=True)
    for x in range(26, 36):
        for y in range(19, 24):
            r = noise(x, y, 6)
            if r < 0.55:
                s.put(x, y, (96, 164, 74) if r < 0.3 else (232, 236, 200))
    for x, y in ((22, 21), (23, 22), (31, 25), (19, 26)):
        s.put(x, y, (208, 46, 50))
    for x, y in ((12, 27), (13, 27), (27, 28), (28, 28)):
        s.put(x, y, (50, 40, 40))
    steam(s, 18, 15, 10, 0.4)
    steam(s, 29, 14, 9, 2.0)
    return s.outline()


FOODS = {
    "nankinmachi": butaman,
    "akashi": akashiyaki,
    "okayama": kibidango,
    "onomichi": onomichi_ramen,
    "hiroshima": okonomiyaki,
    "hakata": hakata_ramen,
}
