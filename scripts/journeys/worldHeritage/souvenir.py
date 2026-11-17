import math
from artlib.souvenir_kit import OUT, Sprite, WHITE, ellipsoid, mix, noise, pillow, steam


def bowl(s, ramp, cx, cy, rx, ry, rim_y):
    body = ellipsoid(cx, cy, rx, ry, taper=0.1)
    s.shape(lambda x, y: body(x, y) if y >= rim_y else None, ramp, spec=(255, 255, 255), power=20, border=True)


def okkirikomi():
    s = Sprite()
    ceramic = [(150, 162, 176), (186, 196, 208), (214, 222, 230), (236, 240, 244), (252, 252, 254)]
    bowl(s, ceramic, 24, 24, 19, 18, 24)
    for x in range(8, 41):
        s.put(x, 30, (60, 92, 142) if x % 4 < 2 else (96, 128, 176))
    broth = [(138, 98, 58), (170, 124, 76), (196, 150, 98), (216, 176, 122)]
    s.shape(ellipsoid(24, 24, 18, 6, depth=1.5), broth, border=True)
    for x in range(8, 41):
        for y in range(19, 29):
            c = s.get(x, y)
            if c is None or c == OUT:
                continue
            r = noise(x, y, 17)
            if r < 0.34 and (x + y) % 5 < 3:
                s.put(x, y, (246, 238, 214) if r < 0.2 else (222, 208, 176))
            elif r < 0.4:
                s.put(x, y, (226, 120, 48))
            elif r > 0.93:
                s.put(x, y, (96, 156, 70))
    for x, y in ((18, 21), (19, 21), (30, 24), (31, 24), (27, 20)):
        s.put(x, y, (120, 176, 84))
    steam(s, 18, 15, 10, 0.0)
    steam(s, 29, 14, 9, 1.8)
    return s.outline()


def houtou():
    s = Sprite()
    iron = [(18, 18, 22), (30, 30, 36), (46, 46, 54), (64, 64, 74), (92, 92, 104)]
    body = ellipsoid(24, 28, 20, 16, taper=0.12)
    s.shape(lambda x, y: body(x, y) if y >= 26 else None, iron, spec=(190, 192, 204), power=24, border=True)
    for y in range(26, 29):
        s.put(3, y, iron[3])
        s.put(44, y, iron[3])
    for x in range(2, 7):
        s.put(x, 27, iron[2])
    for x in range(41, 46):
        s.put(x, 27, iron[2])
    soup = [(112, 66, 34), (142, 88, 46), (170, 112, 62), (194, 138, 82)]
    s.shape(ellipsoid(24, 26, 18, 7, depth=1.5), soup, border=True)
    kabocha = [(176, 84, 22), (210, 118, 30), (234, 154, 44), (248, 188, 72)]
    for kx, ky in ((15, 25), (26, 22), (32, 28), (20, 29)):
        s.shape(pillow([(kx - 4, ky - 2), (kx + 3, ky - 3), (kx + 4, ky + 2), (kx - 3, ky + 3)], 2.5), kabocha)
        for dx in (-3, -2, -1, 0):
            s.put(kx + dx, ky - 2 + (dx + 3) % 2, (60, 96, 50))
    for x in range(8, 41):
        for y in range(21, 33):
            if s.get(x, y) is None or s.get(x, y) == OUT:
                continue
            r = noise(x, y, 23)
            if r < 0.08:
                s.put(x, y, (240, 230, 200))
            elif r > 0.96:
                s.put(x, y, (90, 150, 66))
    steam(s, 17, 17, 10, 0.5)
    steam(s, 30, 16, 9, 2.4)
    return s.outline()


def gohei_mochi():
    s = Sprite()
    stick, stick_dark = (232, 202, 144), (190, 152, 96)
    for y in range(2, 46):
        s.put(23, y, stick)
        s.put(24, y, stick_dark)
    mochi = [(120, 62, 22), (150, 86, 32), (182, 118, 50), (208, 152, 78), (232, 190, 118)]

    def glaze(x, y, n):
        r = noise(x, y, 31)
        return -1 if r < 0.14 else 1 if r > 0.9 else 0

    shape = pillow([(13, 8), (35, 8), (40, 30), (8, 30)], 5.0)
    s.shape(shape, mochi, spec=(255, 226, 170), power=14, tex=glaze, border=True)
    for x in range(14, 35):
        for y in range(10, 30):
            if s.get(x, y) is not None and noise(x, y, 5) > 0.86 and y % 4 in (0, 1):
                s.put(x, y, (86, 40, 16))
    for y in range(31, 38):
        s.put(23, y, stick)
        s.put(24, y, stick_dark)
    return s.outline()


def kakinoha_zushi():
    s = Sprite()
    leaf = [(30, 74, 36), (50, 110, 52), (76, 148, 70), (108, 182, 96), (150, 212, 130)]

    def vein(x, y, n):
        return 1 if abs((x - 14) - (y - 31)) < 0.6 or abs((x - 14) + (y - 31)) < 0.6 else 0

    wrap = pillow([(14, 18), (28, 31), (14, 44), (2, 31)], 5.0)
    s.shape(wrap, leaf, spec=(220, 244, 200), power=16, tex=vein, border=True)
    for y in range(24, 39):
        s.put(14, y, leaf[0])
    for x in range(8, 21):
        s.put(x, 31, leaf[0])
    rice = [(190, 186, 176), (222, 220, 212), (240, 238, 232), (255, 255, 250)]
    s.shape(pillow([(25, 8), (46, 8), (46, 22), (25, 22)], 4.0), rice, border=True)
    fish = [(176, 70, 62), (214, 104, 86), (240, 142, 112), (252, 184, 150)]

    def stripe(x, y, n):
        return -1 if (x + y) % 5 == 0 else 0

    s.shape(pillow([(26, 11), (45, 11), (45, 20), (26, 20)], 3.0), fish, spec=(255, 226, 206), power=16, tex=stripe, border=True)
    s.shape(pillow([(30, 30), (44, 25), (47, 40), (33, 44)], 4.0), leaf, spec=(220, 244, 200), power=16, border=True)
    return s.outline()


def himeji_oden():
    s = Sprite()
    plate = [(150, 158, 170), (190, 198, 208), (220, 226, 232), (242, 246, 248), (255, 255, 255)]
    s.shape(ellipsoid(24, 30, 22, 14, depth=3.0), plate, spec=(255, 255, 255), power=18, border=True)
    sauce = [(96, 62, 28), (122, 82, 38), (150, 106, 54)]
    s.shape(ellipsoid(24, 30, 17, 9, depth=1.0), sauce, border=True)
    daikon = [(176, 150, 108), (206, 182, 140), (230, 212, 176), (246, 236, 208)]

    def cylinder(x, y):
        if not (9.5 <= x <= 25.5 and 24 <= y <= 33):
            return None
        u = (x - 17.5) / 8.0
        return math.sqrt(max(0.0, 1 - u * u)) * 5

    s.shape(cylinder, daikon, spec=(255, 250, 230), power=16, border=True)
    egg = [(148, 112, 70), (186, 148, 96), (218, 184, 128), (240, 214, 164)]
    s.shape(ellipsoid(32, 27, 6, 7), egg, spec=(255, 240, 210), power=22, border=True)
    konnyaku = [(30, 30, 36), (50, 50, 58), (72, 72, 82), (100, 100, 112)]
    s.shape(pillow([(27, 32), (37, 31), (34, 39)], 3.0), konnyaku, spec=(190, 192, 204), power=18, border=True)
    ginger = [(186, 150, 60), (214, 180, 82), (238, 208, 116)]
    for x in range(14, 25):
        for y in range(20, 25):
            if ((x - 19) / 5.5) ** 2 + ((y - 23) / 3.2) ** 2 <= 1:
                r = noise(x, y, 13)
                s.put(x, y, ginger[0] if r < 0.3 else ginger[1] if r < 0.8 else ginger[2])
    steam(s, 14, 18, 9, 0.2)
    steam(s, 32, 17, 8, 2.0)
    return s.outline()


def momiji_manju():
    s = Sprite()
    cake = [(122, 64, 22), (156, 92, 34), (190, 126, 52), (218, 160, 84), (238, 192, 122)]

    def lobe(theta):
        t = (theta % (2 * math.pi / 5)) / (2 * math.pi / 5)
        return 0.62 + 0.38 * math.cos((t - 0.5) * math.pi * 1.4) ** 2

    def leaf(cx, cy, r, rotate):
        def height(x, y):
            dx, dy = x - cx, y - cy
            d = math.hypot(dx, dy)
            edge = r * lobe(math.atan2(dy, dx) + rotate)
            if d > edge:
                return None
            return math.sqrt(1 - (d / edge) ** 2) * 6

        return height

    def veins(x, y, n):
        return -1 if noise(x, y, 4) < 0.1 else 0

    s.shape(leaf(17, 18, 16, 0.3), cake, spec=(255, 228, 170), power=14, tex=veins, border=True)
    for k in range(5):
        ang = 0.3 + k * 2 * math.pi / 5 + math.pi / 5
        for i in range(1, 9):
            s.put(int(round(17 + math.cos(ang) * i)), int(round(18 + math.sin(ang) * i)), cake[1])
    anko = [(44, 24, 36), (66, 38, 54), (92, 56, 76), (116, 76, 96)]
    s.shape(leaf(31, 32, 14, 1.1), cake[:4], border=True)
    s.shape(leaf(31, 33, 10, 1.1), anko, spec=(180, 140, 160), power=18)
    return s.outline()


FOODS = {
    "tomioka": okkirikomi,
    "fujisan": houtou,
    "shirakawago": gohei_mochi,
    "nara": kakinoha_zushi,
    "himejijo": himeji_oden,
    "itsukushima": momiji_manju,
}
