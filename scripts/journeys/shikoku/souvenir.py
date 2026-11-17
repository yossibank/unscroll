import math
from artlib.souvenir_kit import Sprite, WHITE, ellipsoid, noise, steam


PLATE = [(170, 186, 198), (204, 216, 226), (228, 236, 242), (244, 248, 250), (255, 255, 255)]


def plate(s, cy, rx, ry):
    s.shape(ellipsoid(24, cy, rx, ry, depth=2), PLATE, spec=WHITE, power=40)
    s.shape(ellipsoid(24, cy - 0.5, rx - 6, ry - 2.5, depth=0.6), PLATE[1:])


def katsuo():
    s = Sprite()
    plate(s, 39, 23, 8)
    flesh = [(120, 30, 40), (170, 48, 56), (206, 76, 80), (230, 112, 112), (248, 156, 150)]
    seared = [(70, 40, 28), (104, 62, 42), (140, 90, 60), (176, 124, 88), (206, 160, 118)]

    def slice_at(x, y):
        s.shape(ellipsoid(x, y, 7.5, 5.2, depth=2.4), seared, border=True)
        s.shape(ellipsoid(x, y + 0.4, 5.9, 3.4, depth=2.4), flesh, spec=(255, 214, 206), power=16)

    for x, y in ((12, 36), (22, 33), (32, 30), (14, 26), (26, 22), (36, 22)):
        slice_at(x, y)
    garlic = [(214, 200, 150), (238, 228, 188), (252, 246, 216)]
    for x, y in ((18, 30), (30, 26), (38, 34)):
        s.shape(ellipsoid(x, y, 2.4, 1.8, depth=1), garlic, border=True)
    for x, y in ((20, 38), (27, 37), (33, 38), (16, 22), (30, 18)):
        s.put(x, y, (84, 170, 80))
        s.put(x + 1, y, (120, 200, 100))
    return s.outline()


def kawaebi():
    s = Sprite()
    plate(s, 38, 23, 8)
    fried = [(110, 60, 20), (160, 96, 32), (206, 140, 52), (234, 180, 84), (250, 216, 130)]

    def crisp(x, y, n):
        return -1 if noise(x, y, 51) < 0.16 else 0

    def shrimp(cx, cy, flip):
        for i in range(6):
            a = i / 5 * 2.4 - 1.2
            x = cx + flip * (4 * math.sin(a) * 1.6)
            y = cy - 4 * math.cos(a) * 0.9 + i * 0.3
            s.shape(ellipsoid(x, y, 3.2, 2.6, depth=2.6), fried, spec=(255, 236, 170), power=14, tex=crisp, border=True)
        s.shape(ellipsoid(cx + flip * 6, cy + 3, 2.6, 1.6, depth=1.4), fried, border=True)

    for cx, cy, flip in ((13, 31, 1), (24, 27, -1), (35, 31, 1), (18, 20, -1), (30, 18, 1)):
        shrimp(cx, cy, flip)
    lemon = [(190, 150, 20), (232, 200, 40), (248, 226, 90), (255, 244, 160)]
    s.shape(ellipsoid(40, 36, 5, 4, depth=2.6), lemon, spec=WHITE, power=20, border=True)
    for i in range(3):
        a = i * math.pi / 3
        for k in range(-3, 4):
            s.put(int(40 + math.cos(a) * k), int(36 + math.sin(a) * k * 0.8), (255, 250, 200))
    return s.outline()


def bocchan():
    s = Sprite()
    stick = [(150, 112, 70), (190, 150, 96), (222, 186, 130)]
    for y in range(4, 44):
        s.put(23, y, stick[1])
        s.put(24, y, stick[2])
        s.put(25, y, stick[0])
    dango = [
        [(98, 54, 30), (140, 84, 48), (180, 120, 70), (214, 156, 100), (240, 196, 140)],
        [(214, 168, 40), (240, 206, 70), (252, 230, 112), (255, 244, 166), (255, 252, 214)],
        [(60, 128, 60), (92, 166, 84), (136, 204, 110), (178, 232, 148), (216, 250, 186)],
    ]

    def grain(x, y, n):
        return -1 if noise(x, y, 61) < 0.1 else 1 if noise(x, y, 62) > 0.93 else 0

    for color, cy in zip(dango, (36, 24, 12)):
        s.shape(ellipsoid(24, cy, 10.5, 6.2, depth=7), color, spec=(255, 250, 230), power=16, tex=grain, border=True)
    return s.outline()


def jakoten():
    s = Sprite()
    plate(s, 40, 23, 7)
    fried = [(108, 60, 24), (154, 92, 40), (196, 130, 62), (226, 166, 92), (244, 200, 136)]

    def fleck(x, y, n):
        r = noise(x, y, 71)
        return -2 if r < 0.12 else 1 if r > 0.92 else 0

    for cx, cy, rx, ry in ((16, 28, 13, 8), (32, 22, 13, 8), (28, 33, 12, 7)):
        s.shape(ellipsoid(cx, cy, rx, ry, depth=4), fried, spec=(255, 226, 170), power=12, tex=fleck, border=True)
    for x, y in ((12, 26), (19, 30), (30, 20), (36, 24), (26, 33), (32, 36), (22, 24)):
        s.put(x, y, (70, 40, 28))
    ginger = [(190, 100, 100), (226, 150, 150), (250, 196, 196)]
    s.shape(ellipsoid(8, 38, 3, 2, depth=1), ginger, border=True)
    return s.outline()


def sanuki():
    s = Sprite()
    bowl = [(120, 40, 36), (170, 60, 52), (206, 88, 72), (232, 124, 102), (248, 168, 146)]
    s.shape(ellipsoid(24, 28, 22, 18, depth=13), bowl, spec=(255, 214, 196), power=22)
    s.shape(ellipsoid(24, 24, 20, 9, depth=0.8), [(150, 102, 48), (190, 140, 66), (214, 168, 96)])
    noodle = [(214, 200, 170), (236, 224, 192), (250, 242, 218), (255, 252, 238)]
    for k in range(6):
        y = 18 + k * 2
        for x in range(8, 41):
            yy = int(round(y + math.sin(x * 0.45 + k * 1.3) * 1.1))
            if ((x - 24) / 17) ** 2 + ((yy - 23) / 7.5) ** 2 <= 1:
                s.put(x, yy, noodle[(x + k) % 4])
    s.shape(ellipsoid(20, 17, 6, 3.4, depth=2.4), [(190, 160, 40), (230, 196, 60), (250, 226, 110)], spec=WHITE, power=10, border=True)
    for x, y in ((28, 19), (31, 21), (14, 22), (34, 24), (26, 24), (22, 25)):
        s.put(x, y, (84, 176, 84))
        s.put(x + 1, y, (132, 210, 112))
    steam(s, 18, 12, 9, 0.0)
    steam(s, 30, 12, 8, 2.0)
    return s.outline()


FOODS = {
    "katsurahama": katsuo,
    "shimanto": kawaebi,
    "dogo": bocchan,
    "shimanami": jakoten,
    "konpira": sanuki,
}
