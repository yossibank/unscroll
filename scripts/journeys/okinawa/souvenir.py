import math
from artlib.souvenir_kit import OUT, Sprite, WHITE, ellipsoid, noise, pillow, steam


def chinsuko():
    s = Sprite()
    plate = [(170, 186, 198), (204, 216, 226), (228, 236, 242), (244, 248, 250), (255, 255, 255)]
    s.shape(ellipsoid(24, 40, 23, 6.5, depth=2), plate, spec=WHITE, power=40)
    s.shape(ellipsoid(24, 39.5, 17, 4, depth=0.6), plate[1:])
    biscuit = [(150, 108, 60), (190, 146, 88), (222, 184, 124), (240, 212, 156), (252, 236, 190)]

    def crumb(x, y, n):
        return -1 if noise(x, y, 17) < 0.14 else 0

    def stick(x0, y0, x1, y1):
        s.shape(pillow([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], 3), biscuit, tex=crumb, border=True)

    stick(5, 30, 23, 38)
    stick(25, 30, 43, 38)
    stick(9, 20, 27, 29)
    stick(21, 12, 39, 21)
    for x, y in ((14, 24), (30, 16), (34, 33), (12, 34)):
        s.put(x, y, (170, 52, 56))
    return s.outline()


def sataandagi():
    s = Sprite()
    dough = [(96, 52, 22), (134, 78, 32), (170, 108, 46), (200, 140, 66), (226, 172, 96), (244, 202, 134)]

    def crack(x, y, n):
        r = noise(x, y, 23)
        return -2 if r < 0.1 else 1 if r > 0.93 else 0

    def crown(cx, cy, rx, ry):
        base = ellipsoid(cx, cy, rx, ry, depth=rx)

        def height(x, y):
            h = base(x, y)
            if h is None:
                return None
            split = abs(x - cx) < 1.1 and y < cy + 1
            return h - 2.5 if split else h

        return height

    s.shape(crown(14, 33, 12, 11), dough, spec=(255, 232, 180), power=22, tex=crack)
    s.shape(crown(34, 33, 12, 11), dough, spec=(255, 232, 180), power=22, tex=crack, border=True)
    s.shape(crown(24, 21, 12, 11), dough, spec=(255, 232, 180), power=22, tex=crack, border=True)
    for x in range(4, 46):
        for y in range(10, 44):
            c = s.get(x, y)
            if c is None or c == OUT:
                continue
            if noise(x, y, 33) > 0.97:
                s.put(x, y, (255, 250, 236))
    return s.outline()


def beniimotart():
    s = Sprite()
    shell = [(130, 82, 40), (168, 112, 56), (204, 150, 84), (228, 180, 112), (244, 210, 150)]

    def flute(x, y, n):
        return -1 if int(x) % 3 == 0 else 0

    s.shape(ellipsoid(24, 33, 21, 12, depth=4), shell, tex=flute, border=True)
    jam = [(64, 28, 96), (92, 44, 130), (122, 68, 160), (152, 98, 186), (184, 134, 210), (214, 176, 230)]

    def swirl(x, y, n):
        a = math.atan2(y - 27, (x - 24) * 1.8)
        d = math.hypot(x - 24, (y - 27) * 1.8)
        return 1 if (a + d * 0.5) % 1.3 < 0.4 else 0

    s.shape(ellipsoid(24, 27, 17, 10, depth=8), jam, spec=(240, 226, 250), power=18, tex=swirl, border=True)
    for x, y in ((16, 21), (24, 18), (32, 22), (21, 26)):
        s.put(x, y, (246, 236, 250))
    return s.outline()


def okinawasoba():
    s = Sprite()
    bowl = [(120, 130, 150), (160, 170, 188), (196, 204, 218), (226, 232, 242), (250, 252, 255)]

    def pattern(x, y, n):
        return -2 if 30 <= y <= 32 and int(x) % 4 < 2 else 0

    side = ellipsoid(24, 24, 22, 20)
    s.shape(lambda x, y: side(x, y) if y >= 26 else None, bowl, spec=WHITE, power=30, tex=pattern, border=True)
    broth = [(150, 98, 44), (186, 132, 62), (214, 166, 88), (234, 196, 118)]
    s.shape(ellipsoid(24, 26, 20.5, 6.5, depth=1.5), broth)
    noodle = [(222, 190, 112), (240, 214, 140), (252, 234, 172)]
    for i in range(9):
        x0 = 9 + i * 3
        for y in range(22, 30):
            nx = x0 + int(2 * math.sin(y * 0.9 + i))
            if ((nx - 24) / 17) ** 2 + ((y - 26) / 5) ** 2 < 1:
                s.put(nx, y, noodle[(i + y) % 3])
    pork = [(96, 46, 28), (140, 76, 44), (184, 112, 66), (214, 148, 98)]
    s.shape(pillow([(10, 22), (24, 20), (27, 27), (13, 30)], 3), pork, border=True)
    fat = (250, 232, 206)
    for x in range(13, 26):
        s.put(x, 26 - (x - 13) // 6, fat)
    kama = [(210, 96, 110), (232, 140, 150), (250, 196, 202), (255, 232, 232)]
    s.shape(ellipsoid(34, 24, 5, 4, depth=2.5), kama, border=True)
    for x, y in ((29, 28), (35, 29), (21, 22), (27, 31), (38, 27)):
        s.put(x, y, (66, 160, 72))
        s.put(x + 1, y, (120, 200, 96))
    steam(s, 18, 15, 9, 0.0)
    steam(s, 28, 14, 8, 1.8)
    return s.outline()


def umibudo():
    s = Sprite()
    plate = [(110, 160, 180), (150, 196, 212), (190, 224, 234), (224, 242, 248), (250, 254, 255)]
    s.shape(ellipsoid(24, 38, 23, 8, depth=2), plate, spec=WHITE, power=40)
    s.shape(ellipsoid(24, 37, 17, 5, depth=0.6), plate[1:])
    stem = (96, 170, 84)
    for sx in (-12, -5, 3, 11):
        for i in range(12):
            s.put(24 + sx + int(sx * i / 24), 34 - i, stem)
    grape = [(30, 110, 60), (52, 150, 76), (86, 190, 96), (130, 220, 126), (190, 246, 170)]
    balls = []
    for row, y in enumerate(range(33, 8, -5)):
        count = max(2, 7 - row)
        for i in range(count):
            x = 24 + (i - (count - 1) / 2) * 5.4 + noise(i, row, 41) * 1.6 - 0.8
            balls.append((x, y + noise(row, i, 42) * 2 - 1))
    for x, y in sorted(balls, key=lambda p: p[1]):
        s.shape(ellipsoid(x, y, 3.4, 3.4, depth=3), grape, spec=(240, 255, 230), power=14, border=True)
    return s.outline()


FOODS = {
    "shurijo": chinsuko,
    "sefautaki": sataandagi,
    "manzamo": beniimotart,
    "bise": okinawasoba,
    "kourijima": umibudo,
}
