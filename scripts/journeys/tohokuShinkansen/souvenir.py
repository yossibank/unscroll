import math
from artlib.souvenir_kit import Sprite, WHITE, ellipsoid, mix, noise, pillow, steam

WOOD = [(112, 76, 44), (148, 106, 64), (182, 140, 92), (210, 172, 122), (232, 204, 158)]
RICE = [(176, 184, 196), (206, 212, 222), (230, 234, 240), (246, 248, 250), (255, 255, 255)]
SHELL = [(150, 112, 112), (190, 148, 140), (220, 184, 170), (240, 214, 200), (252, 240, 232)]


def tray(s, left, top, right, bottom):
    s.shape(pillow([(left, top), (right, top), (right, bottom), (left, bottom)], 4), WOOD, spec=(250, 232, 196), power=40, border=True)
    s.shape(pillow([(left + 3, top + 3), (right - 3, top + 3), (right - 3, bottom - 3), (left + 3, bottom - 3)], 2), [(150, 112, 70), (176, 138, 90)])


def grains(x, y, n):
    return 1 if noise(x, y, 17) > 0.9 else -1 if noise(x, y, 19) < 0.1 else 0


def gyoza():
    s = Sprite()
    tray(s, 3, 14, 45, 44)
    skin = [(122, 70, 30), (172, 112, 52), (214, 164, 88), (238, 206, 136), (252, 236, 190)]

    def brown(x, y, n):
        return -1 if y > 0 and noise(x, y, 5) < 0.28 else 0

    for cx, cy in ((14, 22), (31, 22), (14, 34), (31, 34)):
        s.shape(ellipsoid(cx, cy, 8, 5, depth=4), skin, spec=(255, 244, 214), power=20, tex=brown, border=True)
        for k in range(-5, 6, 2):
            s.put(cx + k, cy - 4 + (abs(k) // 3), (250, 236, 196))
    for x, y in ((40, 18), (41, 19), (40, 40), (39, 41)):
        s.put(x, y, (98, 150, 62))
    return s.outline()


def gyutan():
    s = Sprite()
    tray(s, 3, 14, 45, 44)
    s.shape(ellipsoid(13, 29, 8, 12, depth=5), RICE, spec=WHITE, power=30, tex=grains, border=True)
    meat = [(70, 34, 24), (112, 58, 38), (150, 88, 56), (188, 124, 84), (214, 160, 116)]

    def sear(x, y, n):
        return -1 if noise(x // 2, y, 8) < 0.22 else 0

    for cy in (20, 29, 38):
        s.shape(ellipsoid(32, cy, 12, 4.6, depth=3), meat, spec=(240, 200, 170), power=18, tex=sear, border=True)
    for y in range(19, 40):
        for x in range(21, 24):
            if noise(x, y, 3) > 0.5 and s.get(x, y) is not None and y % 9 in (5, 6, 7):
                s.put(x, y, (96, 150, 62))
    return s.outline()


def wankosoba():
    s = Sprite()
    red = [(70, 18, 18), (112, 28, 26), (156, 42, 36), (196, 64, 50), (226, 98, 76)]
    soba = [(176, 160, 120), (206, 192, 150), (226, 214, 176), (240, 232, 202), (252, 248, 228)]

    def strands(x, y, n):
        return 1 if (x + int(y * 0.4)) % 4 == 0 else 0

    for cx, cy in ((11, 38), (25, 38), (39, 38)):
        bowl = ellipsoid(cx, cy - 2, 10, 9, depth=6)
        s.shape(lambda x, y, b=bowl, c=cy: b(x, y) if y >= c - 3 else None, red, spec=(255, 214, 196), power=22, border=True)
        s.shape(ellipsoid(cx, cy - 3, 8, 2.6, depth=1.5), soba, tex=strands)
    bowl = ellipsoid(24, 26, 13, 11, depth=7)
    s.shape(lambda x, y: bowl(x, y) if y >= 21 else None, red, spec=(255, 214, 196), power=22, border=True)
    s.shape(ellipsoid(24, 20.5, 11, 4.6, depth=3), soba, spec=WHITE, power=26, tex=strands, border=True)
    for x, y in ((21, 17), (24, 16), (27, 18), (23, 19)):
        s.put(x, y, (98, 156, 66))
    steam(s, 22, 14, 8, 0.0)
    steam(s, 28, 13, 7, 1.7)
    return s.outline()


def ichigoni():
    s = Sprite()
    lacquer = [(24, 16, 18), (46, 24, 26), (80, 40, 38), (122, 60, 52), (160, 86, 70)]
    bowl = ellipsoid(24, 24, 21, 19, depth=9)
    s.shape(lambda x, y: bowl(x, y) if y >= 22 else None, lacquer, spec=(240, 190, 170), power=24, border=True)
    s.shape(ellipsoid(24, 22, 19, 6, depth=2), [(150, 106, 52), (196, 150, 76), (226, 190, 112)], spec=(255, 240, 190), power=20, border=True)
    urchin = [(176, 104, 24), (216, 142, 36), (240, 178, 56), (252, 208, 88), (255, 232, 140)]
    for cx, cy, r in ((16, 22, 5), (26, 20, 5.5), (33, 23, 4.5), (22, 24, 4)):
        s.shape(ellipsoid(cx, cy, r, r * 0.6, depth=2.5), urchin, spec=(255, 244, 200), power=16, border=True)
    for cx, cy in ((12, 24), (30, 20)):
        s.shape(ellipsoid(cx, cy, 3.5, 2, depth=1.5), [(150, 130, 120), (200, 182, 168), (232, 220, 206)], border=True)
    for x, y in ((20, 21), (28, 23), (35, 21)):
        s.put(x, y, (98, 156, 66))
    steam(s, 20, 16, 9, 0.4)
    steam(s, 30, 15, 8, 2.1)
    return s.outline()


def hotate():
    s = Sprite()
    tray(s, 3, 22, 45, 45)

    def ribs(x, y, n):
        return 1 if int(math.hypot(x - 24, y - 40) * 1.3 + math.atan2(y - 40, x - 24) * 6) % 3 == 0 else 0

    fan = [(24, 40)] + [(24 + 21 * math.cos(math.radians(a)), 40 - 22 * math.sin(math.radians(a))) for a in range(20, 161, 20)]
    s.shape(pillow(fan, 6, lift=1), SHELL, spec=WHITE, power=30, tex=ribs, border=True)
    for x in range(20, 29):
        for y in range(38, 44):
            s.put(x, y, (200, 160, 150))
    scallop = [(190, 150, 100), (222, 186, 130), (240, 214, 164), (250, 236, 196), (255, 250, 230)]
    for cx, cy in ((14, 34), (24, 30), (34, 34)):
        s.shape(ellipsoid(cx, cy, 6.5, 5.2, depth=4), scallop, spec=WHITE, power=22, border=True)
        s.put(cx + 3, cy - 2, (214, 120, 70))
    for x, y in ((9, 42), (10, 43), (38, 42), (39, 43)):
        s.put(x, y, (98, 150, 62))
    return s.outline()


FOODS = {
    "utsunomiya": gyoza,
    "sendai": gyutan,
    "morioka": wankosoba,
    "hachinohe": ichigoni,
    "shinaomori": hotate,
}
