import math
from artlib.souvenir_kit import OUT, Sprite, WHITE, ellipsoid, noise, pillow, steam


def plate_ramp():
    return [(170, 186, 198), (204, 216, 226), (228, 236, 242), (244, 248, 250), (255, 255, 255)]


def onumadango():
    s = Sprite()
    wood = [(110, 72, 40), (146, 98, 58), (178, 128, 80), (204, 158, 106), (226, 188, 138)]

    def grain(x, y, n):
        return -1 if int(y) % 4 == 0 else 0

    s.shape(pillow([(3, 38), (45, 38), (45, 45), (3, 45)], 3), wood, tex=grain, border=True)
    stick = (196, 160, 104)
    sauces = [
        [(110, 58, 24), (150, 88, 38), (186, 122, 58), (214, 158, 86), (238, 196, 128)],
        [(52, 26, 38), (84, 44, 58), (116, 66, 80), (148, 96, 106), (180, 132, 140)],
        [(190, 170, 130), (218, 200, 160), (238, 224, 188), (250, 240, 214), (255, 252, 236)],
    ]
    for i, cx in enumerate((10, 24, 38)):
        for y in range(5, 40):
            s.put(cx, y, stick)
        for y in (9, 19, 29):
            s.shape(
                ellipsoid(cx, y + 1, 5.2, 4.8, depth=4.5),
                sauces[i],
                spec=(255, 244, 214),
                power=16,
                border=True,
            )
    for x, y in ((24, 10), (23, 20), (25, 30), (38, 8), (37, 20), (39, 28)):
        s.put(x, y, (74, 52, 40) if x > 30 else (252, 248, 232))
    return s.outline()


def jagabutter():
    s = Sprite()
    plate = plate_ramp()
    s.shape(ellipsoid(24, 40, 23, 6.5, depth=2), plate, spec=WHITE, power=40)
    s.shape(ellipsoid(24, 39.5, 17, 4, depth=0.6), plate[1:])
    skin = [(104, 64, 30), (150, 100, 50), (186, 138, 74), (212, 170, 102), (232, 200, 132)]

    def speck(x, y, n):
        return -1 if noise(x, y, 61) < 0.14 else 0

    s.shape(ellipsoid(24, 29, 20, 12, depth=9), skin, tex=speck, border=True)
    flesh = [(212, 168, 60), (236, 198, 86), (250, 222, 124), (255, 238, 164), (255, 248, 206)]
    s.shape(ellipsoid(24, 23, 15, 6.5, depth=4), flesh, spec=(255, 252, 230), power=12, border=True)
    butter = [(220, 176, 52), (244, 208, 78), (255, 232, 118), (255, 244, 170), (255, 252, 214)]
    s.shape(pillow([(19, 15), (29, 14), (30, 22), (20, 23)], 3, lift=2), butter, border=True)
    for x, y in ((12, 24), (35, 25), (16, 27), (32, 21)):
        s.put(x, y, (86, 170, 84))
    steam(s, 14, 12, 8, 0.0)
    steam(s, 34, 11, 7, 1.9)
    return s.outline()


def otarusushi():
    s = Sprite()
    wood = [(110, 72, 40), (146, 98, 58), (178, 128, 80), (204, 158, 106), (226, 188, 138)]

    def grain(x, y, n):
        return -1 if int(x) % 5 == 0 else 0

    s.shape(ellipsoid(24, 40, 23, 6.5, depth=2), wood, tex=grain, border=True)
    rice = [(190, 190, 184), (220, 220, 214), (240, 240, 236), (252, 252, 250), (255, 255, 255)]
    salmon = [(206, 84, 52), (232, 120, 74), (248, 156, 108), (255, 190, 146), (255, 222, 190)]
    tuna = [(120, 28, 44), (160, 44, 60), (194, 70, 84), (222, 108, 118), (244, 160, 164)]

    def fat(x, y, n):
        return 1 if (int(x) + int(y) * 2) % 7 == 0 else 0

    for cx, cy, fish in ((13, 31, salmon), (35, 31, tuna)):
        s.shape(ellipsoid(cx, cy + 1, 9, 5.5, depth=4), rice, border=True)
        s.shape(ellipsoid(cx, cy - 2, 10.5, 4.5, depth=3), fish, spec=(255, 240, 230), power=14, tex=fat, border=True)
    green = [(20, 40, 28), (30, 62, 40), (44, 86, 56), (60, 110, 72)]
    s.shape(pillow([(16, 14), (32, 14), (32, 27), (16, 27)], 3), rice, border=True)
    s.shape(pillow([(15, 15), (33, 15), (33, 22), (15, 22)], 2), green, border=True)
    roe = [(190, 52, 24), (226, 90, 30), (248, 138, 52), (255, 186, 96)]
    for i in range(10):
        x = 18 + (i % 5) * 3 + (i // 5) * 1.5
        y = 15 + (i // 5) * 2.5 + noise(i, 1, 62) * 1.5
        s.shape(ellipsoid(x, y, 2.2, 2.2, depth=2), roe, spec=(255, 236, 210), power=8)
    return s.outline()


def bowl(s, rim, soup, band):
    def pattern(x, y, n):
        return -2 if band and 31 <= y <= 33 and int(x) % 5 < 2 else 0

    side = ellipsoid(24, 24, 22, 20)
    s.shape(lambda x, y: side(x, y) if y >= 26 else None, rim, spec=WHITE, power=30, tex=pattern, border=True)
    s.shape(ellipsoid(24, 26, 20.5, 6.5, depth=1.5), soup)


def noodles(s, colors):
    for i in range(9):
        x0 = 9 + i * 3
        for y in range(22, 30):
            nx = x0 + int(2 * math.sin(y * 0.9 + i))
            if ((nx - 24) / 17) ** 2 + ((y - 26) / 5) ** 2 < 1:
                s.put(nx, y, colors[(i + y) % 3])


def misoramen():
    s = Sprite()
    red = [(110, 30, 30), (156, 44, 40), (196, 66, 54), (226, 104, 84), (248, 150, 126)]
    miso = [(160, 96, 40), (200, 134, 56), (226, 164, 82), (244, 192, 112)]
    bowl(s, red, miso, True)
    noodles(s, [(232, 194, 110), (246, 216, 140), (255, 238, 176)])
    pork = [(100, 50, 30), (146, 82, 50), (190, 118, 74), (220, 152, 106)]
    s.shape(ellipsoid(15, 24, 6, 4.5, depth=3), pork, border=True)
    s.shape(ellipsoid(23, 21, 6, 4.5, depth=3), pork, border=True)
    corn = [(210, 150, 20), (240, 190, 40), (255, 222, 90)]
    for x, y in ((31, 22), (34, 24), (32, 26), (36, 27), (29, 25), (35, 21)):
        s.shape(ellipsoid(x, y, 1.6, 1.6, depth=1.6), corn)
    s.shape(pillow([(26, 28), (31, 28), (31, 31), (26, 31)], 1), [(250, 244, 210), (255, 255, 240)], border=True)
    for x, y in ((12, 27), (20, 29), (28, 22), (37, 29), (17, 21)):
        s.put(x, y, (66, 160, 72))
        s.put(x + 1, y, (120, 200, 96))
    steam(s, 18, 15, 9, 0.0)
    steam(s, 29, 14, 8, 1.8)
    return s.outline()


def furanomelon():
    s = Sprite()
    rind = [(40, 90, 50), (60, 124, 66), (92, 162, 84), (132, 196, 110), (176, 224, 146)]

    def net(x, y, n):
        return 1 if int(x) % 4 == 0 or int(y) % 4 == 0 else (-1 if noise(x, y, 71) < 0.1 else 0)

    s.shape(ellipsoid(18, 22, 16, 15, depth=13), rind, spec=(230, 250, 210), power=14, tex=net, border=True)
    for i in range(5):
        s.put(17 + i // 2, 7 - i, (92, 120, 60))
        s.put(18 + i // 2, 7 - i, (68, 90, 48))

    def crescent(rx, ry, cy):
        base = ellipsoid(34, cy, rx, ry, depth=ry)
        return lambda x, y: base(x, y) if y >= cy - 1 else None

    s.shape(crescent(13, 12, 30), rind, border=True)
    flesh = [(226, 118, 30), (246, 156, 52), (252, 190, 84), (255, 218, 124), (255, 238, 168)]
    s.shape(crescent(11, 9.5, 29.5), flesh, spec=(255, 248, 210), power=10, border=True)
    green = [(120, 190, 100), (160, 216, 128), (200, 236, 160)]
    s.shape(crescent(12, 10.5, 30), green)
    s.shape(crescent(11, 9.5, 29.5), flesh, spec=(255, 248, 210), power=10)
    for x, y in ((30, 33), (34, 35), (38, 33), (32, 38)):
        s.put(x, y, (255, 246, 214))
    return s.outline()


def asahikawaramen():
    s = Sprite()
    white = [(150, 160, 180), (190, 200, 216), (222, 230, 242), (244, 248, 252), (255, 255, 255)]
    shoyu = [(70, 36, 16), (104, 56, 24), (140, 82, 36), (172, 110, 52)]
    bowl(s, white, shoyu, True)
    noodles(s, [(226, 190, 112), (240, 212, 140), (250, 232, 170)])
    for x in range(9, 40, 3):
        for y in range(25, 30):
            if ((x - 24) / 17) ** 2 + ((y - 27) / 5) ** 2 < 1 and noise(x, y, 77) > 0.7:
                s.put(x, y, (236, 190, 90))
    pork = [(100, 50, 30), (146, 82, 50), (190, 118, 74), (220, 152, 106)]
    s.shape(ellipsoid(14, 24, 6, 4.5, depth=3), pork, border=True)
    s.shape(ellipsoid(32, 23, 5, 4, depth=3), [(210, 150, 130), (236, 176, 164), (250, 208, 200), (255, 236, 232)], border=True)
    for i in range(3):
        s.shape(pillow([(21 + i * 2, 25), (22 + i * 2, 25), (22 + i * 2, 30), (21 + i * 2, 30)], 1), [(180, 130, 60), (214, 168, 90)])
    s.shape(pillow([(36, 14), (42, 14), (42, 25), (36, 25)], 2), [(16, 30, 24), (30, 52, 38), (44, 76, 54)], border=True)
    for x, y in ((12, 28), (19, 22), (27, 21), (34, 29), (26, 30)):
        s.put(x, y, (66, 160, 72))
        s.put(x + 1, y, (120, 200, 96))
    steam(s, 18, 15, 9, 0.0)
    steam(s, 28, 14, 8, 1.8)
    return s.outline()


FOODS = {
    "onuma": onumadango,
    "toyako": jagabutter,
    "otaru": otarusushi,
    "sapporo": misoramen,
    "furano": furanomelon,
    "asahikawa": asahikawaramen,
}
