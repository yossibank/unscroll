import math
from artlib.souvenir_kit import Sprite, WHITE, ellipsoid, noise, pillow, steam


def monaka():
    s = Sprite()
    shell = [(150, 106, 56), (190, 144, 84), (222, 180, 116), (240, 208, 150), (252, 232, 188)]

    def petal(x, y, n):
        return -1 if int(abs(x - 24) + abs(y - 30)) % 5 == 0 else 0

    s.shape(ellipsoid(31, 15, 15, 8, depth=5), shell, tex=petal, border=True)
    s.shape(ellipsoid(22, 33, 19, 9, depth=5), shell, tex=petal, border=True)
    bean = [(70, 22, 36), (104, 36, 50), (136, 54, 66), (164, 78, 88), (190, 108, 112)]

    def grain(x, y, n):
        return 1 if noise(x, y, 31) > 0.82 else 0

    s.shape(ellipsoid(22, 28, 15, 8, depth=7), bean, spec=(236, 190, 190), power=16, tex=grain, border=True)
    for x, y in ((16, 25), (24, 23), (29, 29)):
        s.put(x, y, (226, 164, 168))
    return s.outline()


def kaminarioshi():
    s = Sprite()
    puff = [(160, 112, 58), (200, 150, 84), (226, 184, 116), (242, 212, 152), (252, 236, 196)]

    def grains(x, y, n):
        r = noise(x, y, 41)
        return -2 if r < 0.12 else 1 if r > 0.8 else 0

    def block(x0, y0, x1, y1):
        s.shape(pillow([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], 3), puff, tex=grains, border=True)

    block(4, 28, 26, 42)
    block(24, 28, 44, 42)
    block(12, 14, 36, 29)
    for x, y in ((9, 33), (31, 36), (20, 20), (28, 22), (16, 38), (39, 32)):
        s.put(x, y, (118, 70, 38))
        s.put(x + 1, y, (150, 96, 52))
    return s.outline()


def ningyoyaki():
    s = Sprite()
    cake = [(130, 76, 34), (170, 104, 46), (206, 138, 62), (230, 168, 92), (246, 200, 132)]

    def face(cx, cy):
        def tex(x, y, n):
            dx, dy = x - cx, y - cy
            if abs(abs(dx) - 3) < 0.8 and abs(dy + 1) < 1:
                return -3
            if abs(dx) < 2.5 and abs(dy - 3) < 0.7:
                return -3
            return 0

        return tex

    for cx, cy in ((14, 17), (34, 17), (24, 35)):
        s.shape(ellipsoid(cx, cy, 11, 11, depth=5), cake, spec=(255, 232, 176), power=14, tex=face(cx, cy), border=True)
    return s.outline()


def monjayaki():
    s = Sprite()
    iron = [(52, 56, 66), (84, 90, 102), (118, 126, 140), (156, 166, 180), (200, 208, 218)]
    s.shape(ellipsoid(24, 31, 22, 12, depth=3), iron, spec=WHITE, power=30, border=True)
    s.shape(ellipsoid(24, 30, 17, 8, depth=1), iron[:3])
    cabbage = [(70, 130, 60), (104, 164, 78), (150, 200, 110), (206, 232, 160)]
    for i in range(26):
        a = i / 26 * math.tau
        x, y = 24 + math.cos(a) * 13, 30 + math.sin(a) * 6
        s.shape(ellipsoid(x, y, 2.6, 1.9, depth=1.4), cabbage)
    batter = [(150, 100, 52), (186, 134, 70), (214, 168, 98), (236, 198, 132)]

    def bubble(x, y, n):
        return 1 if noise(x, y, 51) > 0.9 else 0

    s.shape(ellipsoid(24, 30, 9, 4.2, depth=1.6), batter, tex=bubble)
    for x, y in ((18, 31), (30, 29), (25, 33), (21, 28)):
        s.put(x, y, (236, 120, 80))
    scoop = [(150, 158, 172), (190, 198, 210), (222, 228, 238), (248, 250, 252)]
    s.shape(pillow([(34, 36), (44, 36), (44, 40), (34, 40)], 2), scoop, border=True)
    s.shape(pillow([(41, 33), (46, 33), (46, 43), (41, 43)], 2), scoop, border=True)
    steam(s, 20, 20, 8, 0.0)
    steam(s, 28, 20, 9, 2.0)
    return s.outline()


def dorayaki():
    s = Sprite()
    skin = [(124, 70, 30), (164, 96, 42), (200, 130, 58), (226, 160, 84), (244, 192, 120)]
    s.shape(ellipsoid(24, 36, 20, 7, depth=4), skin, border=True)
    bean = [(60, 20, 34), (96, 34, 48), (130, 52, 64), (160, 78, 86)]

    def grain(x, y, n):
        return 1 if noise(x, y, 61) > 0.8 else 0

    s.shape(ellipsoid(24, 30, 19, 4.5, depth=3), bean, tex=grain, border=True)
    top = ellipsoid(24, 24, 21, 12, depth=10)

    def pale(x, y, n):
        inside = ((x - 22) / 10) ** 2 + ((y - 19) / 5) ** 2 < 1
        return 2 if inside else 0

    s.shape(lambda x, y: top(x, y) if y <= 28 else None, skin, spec=(255, 232, 176), power=18, tex=pale, border=True)
    return s.outline()


FOODS = {
    "kokyo": monaka,
    "asakusa": kaminarioshi,
    "skytree": ningyoyaki,
    "odaiba": monjayaki,
    "tokyotower": dorayaki,
}
