import math
from artlib.souvenir_kit import OUT, Sprite, WHITE, ellipsoid, noise, pillow, steam


def kuro_tamago():
    s = Sprite()
    ramp = [(20, 19, 24), (32, 31, 38), (46, 45, 54), (62, 61, 72), (84, 83, 96), (112, 111, 126)]

    def shell(x, y, n):
        r = noise(x, y, 3)
        return -1 if r < 0.12 else 1 if r > 0.93 else 0

    s.shape(ellipsoid(14, 32, 10, 12.5, taper=0.18), ramp, spec=(214, 216, 226), power=30, tex=shell)
    s.shape(ellipsoid(29, 28, 12, 15, taper=0.18), ramp, spec=(226, 228, 236), power=30, tex=shell, border=True)
    s.outline()
    steam(s, 22, 11, 9, 0.0)
    steam(s, 30, 9, 8, 1.8)
    return s


def shizuoka_oden():
    s = Sprite()
    stick, stick_dark = (226, 194, 136), (188, 150, 96)
    for y in range(1, 47):
        s.put(23, y, stick)
        s.put(24, y, stick_dark)
    hanpen = [(52, 48, 50), (72, 66, 66), (96, 88, 86), (122, 112, 106), (150, 138, 128)]

    def fish(x, y, n):
        r = noise(x, y, 11)
        return -1 if r < 0.18 else 1 if r > 0.9 else 0

    moon = ellipsoid(24, 15, 12, 11, depth=4)
    s.shape(lambda x, y: moon(x, y) if y <= 15 else None, hanpen, tex=fish)
    daikon = [(116, 66, 28), (150, 92, 40), (184, 122, 58), (210, 152, 82), (232, 186, 118), (246, 214, 156)]

    def cylinder(x, y):
        if not (12.5 <= x <= 35.5 and 19 <= y <= 29):
            return None
        u = (x - 24) / 11.5
        return math.sqrt(max(0.0, 1 - u * u)) * 6

    def fibers(x, y, n):
        return 1 if (x * 3 + int(y * 0.5)) % 7 == 0 else 0

    s.shape(cylinder, daikon, spec=(255, 232, 190), power=18, tex=fibers, border=True)
    s.shape(ellipsoid(24, 19.5, 11.5, 2.6, depth=1.2), daikon[2:], border=False)
    egg = [(102, 56, 26), (138, 80, 36), (172, 108, 52), (202, 140, 76), (226, 172, 108), (244, 204, 148)]
    s.shape(ellipsoid(24, 38, 9, 7.5), egg, spec=(255, 236, 200), power=26, border=True)
    for x in range(10, 38):
        for y in range(3, 44):
            c = s.get(x, y)
            if c is None or c == OUT or x in (23, 24) and (y < 6 or y > 44):
                continue
            r = noise(x, y, 29)
            if y < 22 and r < 0.1:
                s.put(x, y, (98, 150, 62) if r < 0.05 else (232, 206, 150))
            elif 30 < y < 40 and r < 0.05:
                s.put(x, y, (98, 150, 62))
    return s.outline()


def unaju():
    s = Sprite()
    lacquer = [(16, 12, 14), (28, 22, 24), (42, 34, 36), (60, 50, 52), (86, 74, 76)]
    red = [(110, 22, 18), (150, 36, 28), (186, 52, 38), (214, 80, 58)]

    def box(x, y):
        if 4 <= x <= 44 and 30 <= y <= 45:
            return 3.0 - (0.6 if y > 43 else 0)
        return None

    def box_tex(x, y, n):
        return 1 if y == 31 or (x in (5, 6) and y < 44) else -1 if y > 42 else 0

    s.shape(box, lacquer, tex=box_tex)
    for x in range(5, 44):
        s.put(x, 36, (200, 160, 70) if x % 2 else (170, 132, 54))

    def rim(x, y):
        if 3 <= x <= 45 and 23 <= y <= 30:
            return 2.0
        return None

    s.shape(rim, red, border=True)
    rice = [(196, 192, 182), (226, 224, 214), (244, 242, 234), (255, 255, 250)]

    def rice_area(x, y):
        if 6 <= x <= 42 and 24 <= y <= 28:
            return 1.0
        return None

    s.shape(rice_area, rice, tex=lambda x, y, n: -1 if noise(x, y, 5) < 0.25 else 0)
    eel = [(66, 26, 10), (100, 44, 16), (136, 68, 26), (170, 96, 40), (204, 130, 62), (232, 172, 104)]

    def fillet(x0, x1, y0, y1):
        def height(x, y):
            if not (x0 <= x <= x1 and y0 <= y <= y1):
                return None
            u = (x - (x0 + x1) / 2) / ((x1 - x0) / 2)
            v = (y - (y0 + y1) / 2) / ((y1 - y0) / 2)
            edge = max(abs(u) ** 6, abs(v) ** 6)
            if edge > 1:
                return None
            return (1 - edge) ** 0.3 * 5 + 2 * (1 - v * v)

        return height

    def grilled(x, y, n):
        stripe = (x + y * 0.7) % 7
        if stripe < 1.2:
            return -2
        if noise(x, y, 13) < 0.08:
            return -1
        return 0

    s.shape(fillet(5, 25, 13, 28), eel, spec=(255, 228, 176), power=14, tex=grilled, border=True)
    s.shape(fillet(23, 43, 12, 28), eel, spec=(255, 228, 176), power=14, tex=grilled, border=True)
    for x, y in ((11, 18), (17, 22), (30, 17), (36, 23), (27, 25), (14, 25)):
        s.put(x, y, (96, 146, 58))
    return s.outline()


def tenmusu():
    s = Sprite()
    rice = [(150, 146, 136), (190, 186, 174), (220, 216, 204), (240, 238, 228), (252, 251, 244), (255, 255, 255)]

    def grains(x, y, n):
        cell = noise(x // 2, y // 3, 17)
        if (x + (y // 3) % 2) % 2 == 0 and y % 3 == 0:
            return -1
        return 1 if cell > 0.82 else 0

    def onigiri(x, y):
        if y < 9 or y > 45:
            return None
        t = (y - 9) / 36
        half = 21 * math.sqrt(t)
        if y > 40:
            half -= (y - 40) ** 2 * 0.4
        if half <= 0:
            return None
        u = (x - 24) / half
        if abs(u) > 1:
            return None
        return 9 * math.sqrt(1 - u * u) * (0.6 + 0.4 * math.sqrt(t))

    s.shape(onigiri, rice, tex=grains)
    nori = [(10, 18, 14), (18, 30, 24), (28, 44, 36), (42, 62, 52), (62, 86, 72)]

    def nori_band(x, y):
        if 14 <= x <= 34 and 32 <= y <= 44:
            u = (x - 24) / 10
            return 4 * math.sqrt(max(0.0, 1 - u * u)) + 6
        return None

    s.shape(nori_band, nori, spec=(110, 136, 120), power=10,
            tex=lambda x, y, n: 1 if x % 3 == 0 and noise(x, y, 2) > 0.6 else 0, border=True)
    batter = [(136, 82, 24), (178, 118, 40), (212, 154, 64), (236, 190, 100), (250, 222, 150)]

    def tempura(x, y):
        base = ellipsoid(24, 11, 8, 5.5)(x, y)
        if base is None:
            return None
        return base + 1.6 * noise(int(x) // 2, int(y) // 2, 9)

    s.shape(tempura, batter, border=True)
    tail = [(140, 30, 20), (190, 56, 34), (228, 92, 58), (248, 142, 104)]

    def tail_shape(x, y):
        if 1 <= y <= 7:
            spread = (7 - y) * 0.75 + 1.2
            if abs(x - 25) <= spread:
                return 2 + (1 if (int(x) - 25) % 3 == 0 else 0)
        return None

    s.shape(tail_shape, tail, border=True)
    return s.outline()


def ayu():
    s = Sprite()
    stick, stick_dark = (226, 194, 136), (188, 150, 96)
    for y in range(30, 48):
        s.put(29, y, stick)
        s.put(30, y, stick_dark)
    back = [(44, 50, 40), (66, 74, 60), (92, 100, 82), (122, 128, 104), (154, 158, 130), (190, 190, 162)]
    belly = [(150, 140, 112), (192, 182, 150), (222, 214, 184), (240, 234, 210), (252, 250, 238)]

    def center(x):
        return 24 + 3.2 * math.sin((x - 4) * 0.15)

    def thickness(x):
        t = (x - 3) / 38
        if t < 0 or t > 1:
            return 0
        return 9.5 * (math.sin(math.pi * t) ** 0.65) * (1.1 - 0.35 * t)

    def body(part):
        def height(x, y):
            t = thickness(x)
            if t <= 0.5:
                return None
            v = (y - center(x)) / t
            if abs(v) > 1:
                return None
            if part == "back" and v > 0.25:
                return None
            if part == "belly" and v <= 0.25:
                return None
            return math.sqrt(1 - v * v) * 6

        return height

    def scales(x, y, n):
        if (x + y * 0.5) % 6 < 1:
            return -2
        return -1 if noise(x, y, 23) < 0.15 else 0

    s.shape(body("back"), back, spec=(220, 226, 210), power=30, tex=scales)
    s.shape(body("belly"), belly, tex=lambda x, y, n: -1 if (x + y * 0.5) % 6 < 1 else 0)
    for i in range(7):
        x = 41 + i
        for y in range(int(center(41)) - 2 - i, int(center(41)) + 3 + i):
            if abs(y - center(41)) >= i * 0.6:
                s.put(x, y, (110, 112, 96) if i < 4 else (236, 236, 228))
    for x in range(17, 29):
        top = int(center(x) - thickness(x))
        for k in range(1, 4 - abs(x - 23) // 3):
            s.put(x, top - k, (240, 240, 232) if k > 1 else (124, 126, 106))
    s.put(14, int(center(14)) - 1, (246, 206, 72))
    s.put(15, int(center(15)) - 1, (246, 206, 72))
    s.put(14, int(center(14)), (224, 180, 60))
    ey = int(center(8)) - 3
    for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1)):
        s.put(7 + dx, ey + dy, WHITE)
    s.put(8, ey + 1, (20, 20, 20))
    for y in range(int(center(11)) - 4, int(center(11)) + 5):
        s.put(11, y, (92, 70, 54))
    return s.outline()


def yatsuhashi():
    s = Sprite()
    plate = [(170, 186, 198), (204, 216, 226), (228, 236, 242), (244, 248, 250), (255, 255, 255)]
    s.shape(ellipsoid(24, 40, 23, 6.5, depth=2), plate, spec=WHITE, power=40)
    s.shape(ellipsoid(24, 39.5, 17, 4, depth=0.6), plate[1:])
    matcha = [(64, 92, 44), (92, 126, 60), (124, 158, 80), (158, 190, 108), (192, 216, 148)]
    cinnamon = [(140, 98, 62), (184, 140, 94), (214, 176, 130), (234, 206, 166), (248, 230, 200)]

    def dust(x, y, n):
        return -1 if noise(x, y, 31) < 0.12 else 0

    s.shape(pillow([(30, 8), (19, 37), (45, 37)], 6), matcha, spec=(226, 240, 200), power=40, tex=dust)
    s.shape(pillow([(16, 12), (3, 41), (31, 41)], 6), cinnamon, spec=(255, 246, 226), power=40, tex=dust,
            border=True)
    anko = [(58, 22, 28), (84, 36, 40), (112, 54, 56)]
    for x in range(8, 27):
        for y in (38, 39):
            r = noise(x, y, 41)
            s.put(x, y, anko[0] if r < 0.3 else anko[1] if r < 0.8 else anko[2])
    return s.outline()


FOODS = {
    "ashinoko": kuro_tamago,
    "miho": shizuoka_oden,
    "hamanako": unaju,
    "nagoyajo": tenmusu,
    "biwako": ayu,
    "kiyomizu": yatsuhashi,
}
