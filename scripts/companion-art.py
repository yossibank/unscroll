"""相棒のドット絵を描く。

種と毛の色ごとに 9 枚の 32×32 px の絵を描き、透明な PNG に書く。絵の名前は <種>_<色>_<場面>。
出力先が .xcassets なら、絵ごとに imageset を作る。そうでなければ、PNG と並べた見本を書く。

    python3 -I scripts/companion-art.py <出力先> [種…]
"""
import json
import struct
import sys
import zlib
from pathlib import Path

W = H = 32
T = None
OUT = (36, 34, 32, 255)
FX = (150, 170, 200, 255)
FRAME_NAMES = ["walk", "walk_left", "blink", "wave", "joy", "jump", "sleep", "surprise", "slide"]

SPECIES = {
    "penguin": {
        "kind": "penguin",
        "main": (124, 120, 114, 255),
        "side": (98, 94, 90, 255),
        "body": (186, 182, 178, 255),
        "body_sh": (156, 152, 146, 255),
        "line": (84, 80, 76, 255),
        "face": (248, 246, 241, 255),
        "face_sh": (232, 228, 220, 255),
        "eye": (40, 38, 36, 255),
        "cheek": (242, 198, 184, 255),
        "nose": (78, 74, 72, 255),
        "nose_hi": (126, 122, 120, 255),
    },
    "shiba": {
        "kind": "shiba",
        "main": (78, 70, 70, 255),
        "side": (56, 50, 50, 255),
        "body": (252, 245, 233, 255),
        "body_sh": (236, 225, 208, 255),
        "line": (40, 34, 34, 255),
        "face": (253, 249, 241, 255),
        "face_sh": (238, 228, 210, 255),
        "eye": (44, 34, 30, 255),
        "cheek": (246, 170, 160, 255),
        "nose": (44, 34, 30, 255),
        "ear_in": (214, 162, 104, 255),
        "brow": (222, 170, 110, 255),
    },
    "tanuki": {
        "kind": "tanuki",
        "main": (158, 128, 98, 255),
        "side": (128, 102, 76, 255),
        "body": (238, 226, 202, 255),
        "body_sh": (220, 206, 180, 255),
        "line": (92, 70, 54, 255),
        "face": (250, 244, 232, 255),
        "face_sh": (232, 222, 204, 255),
        "eye": (36, 28, 24, 255),
        "cheek": (240, 168, 156, 255),
        "nose": (36, 28, 24, 255),
        "mask": (82, 64, 52, 255),
        "paw": (82, 64, 52, 255),
    },
}

# 種ごとの毛の色 4 つ。種の色の表のうち、変える色だけを書く。
# speckle は胡麻の毛先の点、patch と patch_sh はペンギンの耳のあたりの色。
COATS = {
    "shiba": {
        "red": {"main": (206, 152, 96), "side": (176, 126, 76), "line": (110, 76, 46), "brow": (206, 152, 96), "ear_in": (240, 200, 156)},
        "black": {},
        "white": {"main": (242, 232, 212), "side": (222, 208, 184), "line": (150, 128, 104), "body": (253, 250, 244), "face": (255, 252, 247), "brow": (242, 232, 212), "ear_in": (240, 192, 172)},
        "sesame": {"main": (190, 130, 80), "side": (160, 106, 64), "line": (96, 62, 40), "brow": (226, 180, 128), "ear_in": (232, 184, 136), "speckle": (92, 62, 44)},
    },
    "tanuki": {
        "brown": {},
        "dark": {"main": (112, 86, 64), "side": (90, 68, 50), "line": (60, 44, 34), "mask": (50, 38, 32), "paw": (50, 38, 32)},
        "gray": {"main": (152, 148, 142), "side": (124, 120, 114), "line": (80, 76, 72), "mask": (68, 64, 62), "paw": (68, 64, 62), "body": (232, 230, 226), "body_sh": (212, 210, 204)},
        "white": {"main": (238, 232, 222), "side": (216, 208, 196), "line": (150, 130, 112), "mask": (196, 170, 146), "paw": (196, 170, 146)},
    },
    "penguin": {
        "gray": {},
        "black": {"main": (56, 58, 66), "side": (38, 40, 46), "line": (26, 26, 30), "body": (246, 246, 244), "body_sh": (220, 220, 224)},
        "emperor": {"main": (50, 54, 64), "side": (34, 38, 46), "line": (24, 26, 30), "face": (252, 249, 240), "face_sh": (232, 226, 212), "body": (250, 246, 232), "body_sh": (226, 220, 204), "patch": (252, 210, 104), "patch_sh": (238, 182, 78)},
        "king": {"main": (128, 100, 78), "side": (104, 80, 62), "line": (70, 52, 40), "body": (158, 128, 102), "body_sh": (136, 108, 86), "face": (246, 240, 232), "face_sh": (228, 220, 208)},
    },
}


def palette(name, coat):
    p = dict(SPECIES[name])
    p.update({k: c + (255,) for k, c in COATS[name][coat].items()})
    return p


def blank():
    return [[T] * W for _ in range(H)]


def put(g, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        g[y][x] = c


def put_behind(g, x, y, c):
    if 0 <= x < W and 0 <= y < H and g[y][x] is T:
        g[y][x] = c


def outline(g):
    src = [row[:] for row in g]
    for y in range(H):
        for x in range(W):
            if src[y][x] is not T:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and src[ny][nx] not in (T, FX):
                    g[y][x] = OUT
                    break


def in_triangle(x, y, a, b, c):
    def s(p, q, r):
        return (p[0] - r[0]) * (q[1] - r[1]) - (q[0] - r[0]) * (p[1] - r[1])

    pt = (x + 0.5, y + 0.5)
    d1, d2, d3 = s(pt, a, b), s(pt, b, c), s(pt, c, a)
    return not ((d1 < 0 or d2 < 0 or d3 < 0) and (d1 > 0 or d2 > 0 or d3 > 0))


def triangle(g, a, b, c, col, behind=True):
    for y in range(H):
        for x in range(W):
            if in_triangle(x, y, a, b, c):
                (put_behind if behind else put)(g, x, y, col)


def half_width(y, top, bottom, squash):
    cy, ry = top + 13, 13 - squash
    v = (y + 0.5 - cy) / ry
    if abs(v) >= 1 or y > bottom:
        return 0
    t = (y - top) / (bottom - top)
    rx = 9.5 + 3.5 * t + squash * 0.6
    return rx * (1 - abs(v) ** 2.5) ** 0.4


def arm(g, p, side, pose, dy):
    sx = 16 + side * 11 - (1 if side > 0 else 0)
    shapes = {
        "out": [(0, 18), (1, 18), (1, 19), (2, 19), (3, 19), (3, 20), (4, 20)],
        "up": [(0, 17), (1, 16), (1, 17), (2, 15), (2, 16), (3, 13), (3, 14), (3, 15), (4, 12), (4, 13)],
    }
    for px, py in shapes.get(pose, []):
        put(g, sx + side * px, py + dy, p["main"])


def ears(g, p, top, shift):
    """頭の後ろに耳を描く。右の耳は左の耳を鏡に映した形。"""
    if p["kind"] == "shiba":
        outer = [(6.5, top - 4.5), (5.5, top + 5.0), (13.0, top + 1.0)]
        inner = [(7.6, top - 1.5), (7.0, top + 3.5), (11.0, top + 1.2)]
    elif p["kind"] == "tanuki":
        cx, cy, r = 8.5, top + 2.0, 2.8
        col = p["mask"]
        for y in range(H):
            for x in range(W):
                for ccx in (cx + shift, 32 - cx + shift):
                    if (x + 0.5 - ccx) ** 2 + (y + 0.5 - cy) ** 2 <= r * r:
                        put_behind(g, x, y, col)
        return
    else:
        return
    for pts, col in ((inner, p["ear_in"]), (outer, p["main"])):
        for mirror in (False, True):
            q = [((32 - x if mirror else x) + shift, y) for x, y in pts]
            triangle(g, *q, col)


def tail(g, p, dy):
    """体の右の後ろに尾を描く。"""
    if p["kind"] == "tanuki":
        for y in range(H):
            for x in range(W):
                u, v = (x + 0.5 - 28.0) / 3.4, (y + 0.5 - 22.0 - dy) / 6.0
                if u * u + v * v <= 1:
                    put_behind(g, x, y, p["mask"] if int((v + 1) * 3.5) % 2 == 0 else p["main"])
    elif p["kind"] == "shiba":
        for y in range(H):
            for x in range(W):
                r = ((x + 0.5 - 27.5) ** 2 + (y + 0.5 - 14.5 - dy) ** 2) ** 0.5
                if r <= 3.6:
                    put_behind(g, x, y, p["body"] if r <= 1.6 or (y + 0.5 > 14.5 + dy and r > 2.6) else p["main"])


def front(p, eyes="open", lf="down", rf="down", ft="stand", dy=0, squash=0, look=0, mouth=False):
    g = blank()
    penguin = p["kind"] == "penguin"
    main, side, body, body_sh, line = p["main"], p["side"], p["body"], p["body_sh"], p["line"]
    face, face_sh, eye = p["face"], p["face_sh"], p["eye"]
    top = 5 + dy + squash
    bottom = 28 if ft != "tuck" else 27 + dy
    arm(g, p, -1, lf, dy)
    arm(g, p, 1, rf, dy)
    hw = {}
    for y in range(H):
        w = half_width(y, top, bottom, squash)
        hw[y] = w
        for x in range(W):
            if abs(x + 0.5 - 16) <= w:
                g[y][x] = main
    if penguin:
        put(g, 16, top - 1, main)
        put(g, 17, top - 2, main)
    belly_y = 17 + dy + squash
    for y in range(H):
        w = hw[y]
        for x in range(W):
            if g[y][x] != main or w == 0:
                continue
            rel = (x + 0.5 - 16) / w
            if not penguin:
                if abs(rel) > 1:
                    continue
                by = (y + 0.5 - (bottom - 5.5)) / 6.8
                bx = (x + 0.5 - 16 - look * 0.5) / 7.0
                if bx * bx + by * by <= 1:
                    g[y][x] = body_sh if rel > 0.3 - look * 0.08 else body
                elif rel > 0.62 - look * 0.1:
                    g[y][x] = side
                continue
            if y >= belly_y + (1 if abs(rel) > 0.82 else 0 if abs(rel) > 0.55 else -1):
                c = body
                if rel > 0.4 - look * 0.08:
                    c = body_sh
                if rel > 0.78 or (y >= bottom - 2 and rel < -0.7):
                    c = side if rel > 0.78 else body_sh
                g[y][x] = c
            elif rel > 0.62 - look * 0.1:
                g[y][x] = side
    if not penguin:
        ears(g, p, top, round(look / 2))
        tail(g, p, dy)
    fy = 13 + dy + squash
    if penguin:
        penguin_mask(g, p, fy, look, hw)
    else:
        muzzle(g, p, fy, look)
    if rf == "down":
        if penguin:
            for y in range(belly_y + 1, belly_y + 8):
                put(g, 23, y, line)
                put(g, 24, y, body_sh)
    eye_xs = (10 + look, 20 + look) if look == 0 else (9 + look, 19 + look)
    for i, ex in enumerate(eye_xs):
        if look < 0 and i == 0 and ex < 6:
            continue
        if eyes == "open":
            for x, y in ((ex, fy), (ex + 1, fy), (ex, fy + 1), (ex + 1, fy + 1)):
                put(g, x, y, eye)
        elif eyes == "closed":
            for x in (ex - 1, ex, ex + 1, ex + 2):
                put(g, x, fy + 1, eye)
        elif eyes == "happy":
            put(g, ex - 1, fy + 1, eye)
            put(g, ex, fy, eye)
            put(g, ex + 1, fy, eye)
            put(g, ex + 2, fy + 1, eye)
        elif eyes == "wide":
            for x in range(ex - 1, ex + 3):
                for y in range(fy - 1, fy + 3):
                    put(g, x, y, eye)
            for x, y in ((ex - 1, fy - 1), (ex + 2, fy - 1), (ex - 1, fy + 2), (ex + 2, fy + 2)):
                put(g, x, y, face if penguin else g[y][x - 1 if x < ex else x + 1] or main)
            put(g, ex, fy, face)
        if p["kind"] == "tanuki" and eyes == "open":
            put(g, ex, fy, face)
        if p["kind"] == "shiba":
            put(g, ex, fy - 2 - (1 if eyes == "wide" else 0), p.get("brow", face))
            put(g, ex + 1, fy - 2 - (1 if eyes == "wide" else 0), p.get("brow", face))
        cx = ex - 1 if i == 0 else ex + 1
        put(g, cx, fy + 2 + (1 if eyes == "wide" else 0), p["cheek"])
        put(g, cx + 1, fy + 2 + (1 if eyes == "wide" else 0), p["cheek"])
    if mouth:
        my = fy + 3 if penguin else fy + 4
        put(g, 15 + look, my, eye)
        put(g, 16 + look, my, eye)
    feet(g, p, ft, bottom)
    speckle(g, p, (11 + look, 20 + look, 0, top + 4), (top + 7, top + 17))
    outline(g)
    return g


def penguin_mask(g, p, fy, look, hw):
    """ペンギンの白い顔の模様と、くちばし。"""
    face, face_sh, eye = p["face"], p["face_sh"], p["eye"]
    paint = (p["main"], p["side"], p["body"], p["body_sh"])
    for y in range(fy - 3, fy + 4):
        for x in range(W):
            if g[y][x] not in paint:
                continue
            for i, ex in enumerate((10.5 + look, 21.5 + look)):
                if ((x + 0.5 - ex) / 4.0) ** 2 + ((y + 0.5 - fy - 0.5) / 3.4) ** 2 <= 1:
                    g[y][x] = face_sh if x - 16 - look > 5 else face
                    outward = (ex - x - 0.5) if i == 0 else (x + 0.5 - ex)
                    if "patch" in p and outward >= 1:
                        g[y][x] = p["patch"] if i == 0 else p["patch_sh"]
            band = 8 if y == fy + 2 else 6
            if y >= fy + 2 and abs(x + 0.5 - 16 - look) <= band and hw[y] - abs(x + 0.5 - 16) > 2:
                g[y][x] = face_sh if x - 16 - look > 5 else face
    bx = 15 + look
    for x, y in ((bx, fy - 2), (bx + 1, fy - 2), (bx, fy - 1), (bx + 1, fy - 1), (bx - 1, fy - 2), (bx + 2, fy - 2)):
        put(g, x, y, eye)
    if look < 0:
        put(g, bx - 2, fy - 1, eye)
        put(g, bx - 1, fy - 1, eye)


def muzzle(g, p, fy, look):
    """けものの白い口もとと、鼻と口。柴犬は頬まで白い。"""
    kind = p["kind"]
    face, face_sh = p["face"], p["face_sh"]
    paint = (p["main"], p["side"])
    if kind == "tanuki":
        for y in range(fy - 2, fy + 4):
            for x in range(W):
                for ex in (10.5 + look, 21.5 + look):
                    if g[y][x] in paint and ((x + 0.5 - ex) / 3.6) ** 2 + ((y + 0.5 - fy - 1.0) / 2.2) ** 2 <= 1:
                        g[y][x] = p["mask"]
    blobs = [(16 + look, fy + 3.0, 4.6, 2.6)]
    if p["kind"] == "shiba":
        blobs = [(16 + look, fy + 3.0, 5.4, 2.8), (10.5 + look, fy + 3.4, 3.2, 2.2), (21.5 + look, fy + 3.4, 3.2, 2.2)]
    for y in range(fy - 1, fy + 7):
        for x in range(W):
            if g[y][x] not in paint:
                continue
            for cx, cy, rx, ry in blobs:
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1:
                    g[y][x] = face_sh if x - 16 - look > 4 else face
    nx = 15 + look
    for x, y in ((nx, fy + 1), (nx + 1, fy + 1), (nx, fy + 2), (nx + 1, fy + 2)):
        put(g, x, y, p["nose"])
    put(g, nx, fy + 1, p["line"])
    put(g, nx - 1, fy + 3, p["line"])
    put(g, nx + 2, fy + 3, p["line"])


def toes(g, line, cx, base, tall=True):
    for y in range(base - (4 if tall else 3), base + 1):
        put(g, cx, y, line)
    for y in range(base - 2, base + 1):
        put(g, cx - 2, y, line)
        put(g, cx + 2, y, line)
    for x in range(cx - 2, cx + 3):
        put(g, x, base, line)


def paw(g, p, cx, base):
    col = p.get("paw", p["main"])
    for x in range(cx - 1, cx + 2):
        put(g, x, base - 1, col)
    for x in range(cx - 2, cx + 3):
        put(g, x, base, col)
    put(g, cx - 1, base, p["line"])
    put(g, cx + 1, base, p["line"])


def feet(g, p, pose, bottom):
    if pose == "tuck":
        return
    foot = (lambda cx, base, tall=True: toes(g, p["line"], cx, base, tall)) if p["kind"] == "penguin" \
        else (lambda cx, base, tall=True: paw(g, p, cx, base))
    if pose == "step":
        foot(10, bottom - 1)
        foot(21, bottom - 2, False)
        for x in range(18, 25):
            if g[bottom][x] in (p["body"], p["body_sh"], p["side"], p["main"]):
                g[bottom][x] = T
    else:
        foot(10, bottom - 1)
        foot(21, bottom - 1)


def speckle(g, p, head, back):
    """胡麻の毛先の点。頭の上（head の範囲）と、影の側の筋（back の行）だけに打つ。"""
    if "speckle" not in p:
        return
    (x0, x1, y0, y1), (b0, b1) = head, back
    for y in range(H):
        for x in range(W):
            on_head = g[y][x] == p["main"] and x0 <= x <= x1 and y0 <= y <= y1
            on_back = g[y][x] == p["side"] and b0 <= y <= b1
            if (on_head or on_back) and (x * 3 + y * 5) % 7 == 0:
                g[y][x] = p["speckle"]


def marks(g, pts):
    for x, y in pts:
        if g[y][x] is T:
            put(g, x, y, FX)


BUBBLE = (222, 238, 252, 255)
BUBBLE_RIM = (128, 162, 206, 255)
EXCLAIM = (226, 92, 76, 255)


def sleep(p):
    """眠る。鼻ちょうちんを顔の上に重ねる。"""
    g = front(p, eyes="closed", squash=2, lf="none", rf="none")
    cx, cy = (19.5, 19.0) if p["kind"] == "penguin" else (19.5, 20.5)
    for y in range(H):
        for x in range(W):
            d = ((x + 0.5 - cx) ** 2 + (y + 0.5 - cy) ** 2) ** 0.5
            if d <= 2.4:
                put(g, x, y, BUBBLE)
            elif d <= 3.3:
                put(g, x, y, BUBBLE_RIM)
    put(g, int(cx) - 1, int(cy) - 1, (255, 255, 255, 255))
    return g


def surprise(p):
    """驚く。左上の空いた所に「!」を出す。"""
    g = front(p, eyes="wide", lf="up", rf="up", mouth=True)
    for x, y in ((1, 0), (2, 0), (1, 1), (2, 1), (1, 2), (2, 2), (1, 3), (2, 3), (1, 5), (2, 5)):
        if g[y][x] is T:
            put(g, x, y, EXCLAIM)
    return g


def slide(p):
    """横向きで、左へ腹ばいにすべる。"""
    g = blank()
    penguin = p["kind"] == "penguin"
    main, side, line = p["main"], p["side"], p["line"]
    hx, hy = 9.5, 19.5
    for y in range(H):
        for x in range(W):
            u, v = (x + 0.5 - 18.5) / 11.5, (y + 0.5 - 23.5) / 5.5
            body = abs(u) ** 2.4 + abs(v) ** 2.4 <= 1
            head = ((x + 0.5 - hx) / 6.5) ** 2 + ((y + 0.5 - hy) / 6.0) ** 2 <= 1
            if body or head:
                g[y][x] = main
                if body and y >= 25:
                    g[y][x] = p["body"] if x < 22 else p["body_sh"]
                elif body and y <= 20 and x >= 15:
                    g[y][x] = side
    if penguin:
        put(g, 10, 12, main)
        put(g, 11, 11, main)
        for x, y in ((0, 19), (1, 19), (2, 19), (1, 20), (2, 20)):
            put(g, x, y, p["nose"])
        put(g, 1, 19, p["nose_hi"])
        for x, y in ((30, 23), (31, 23), (30, 25), (31, 25)):
            put(g, x, y, line)
        for y in range(16, 26):
            for x in range(2, 14):
                if g[y][x] in (main, side) and ((x + 0.5 - 7.5) / 4.0) ** 2 + ((y + 0.5 - 20.5) / 3.2) ** 2 <= 1:
                    g[y][x] = p["patch"] if "patch" in p and x >= 9 else p["face"]
        for x, y in ((15, 21), (16, 21), (17, 22), (18, 22), (19, 22), (20, 23), (21, 23), (22, 23), (23, 24)):
            put(g, x, y, line)
    else:
        slide_beast(g, p)
    for x, y in ((5, 18), (6, 18), (5, 19), (6, 19)):
        put(g, x, y, p["eye"])
    if p["kind"] == "tanuki":
        put(g, 5, 18, p["face"])
    put(g, 7, 21, p["cheek"])
    put(g, 8, 21, p["cheek"])
    speckle(g, p, (5, 14, 0, 16), (16, 22))
    outline(g)
    marks(g, [(x, 16) for x in range(22, 27)] + [(x, 19) for x in range(28, 32)] + [(x, 30) for x in range(18, 25)])
    return g


def slide_beast(g, p):
    """すべるけものの、横顔の耳・口もと・尾・後ろ足。"""
    main = p["main"]
    if p["kind"] == "tanuki":
        for y in range(H):
            for x in range(W):
                if (x + 0.5 - 12.5) ** 2 + (y + 0.5 - 13.5) ** 2 <= 2.6 ** 2:
                    put_behind(g, x, y, p["mask"])
                u, v = (x + 0.5 - 28.5) / 3.0, (y + 0.5 - 18.0) / 5.0
                if u * u + v * v <= 1:
                    put_behind(g, x, y, p["mask"] if int((v + 1) * 3) % 2 == 0 else main)
        for y in range(17, 21):
            for x in range(3, 10):
                if g[y][x] in (main, p["side"]) and ((x + 0.5 - 6.0) / 2.8) ** 2 + ((y + 0.5 - 19.0) / 1.8) ** 2 <= 1:
                    g[y][x] = p["mask"]
    else:
        triangle(g, (14.5, 9.5), (9.5, 15.0), (14.5, 15.5), main)
        triangle(g, (14.0, 11.5), (11.5, 14.6), (13.8, 14.8), p.get("ear_in", main), behind=False)
        for y in range(H):
            for x in range(W):
                r = ((x + 0.5 - 28.0) ** 2 + (y + 0.5 - 18.0) ** 2) ** 0.5
                if r <= 3.4:
                    put_behind(g, x, y, p["body"] if r <= 1.5 else main)
    for y in range(16, 25):
        for x in range(0, 12):
            if ((x + 0.5 - 4.0) / 4.2) ** 2 + ((y + 0.5 - 21.5) / 2.6) ** 2 <= 1:
                if g[y][x] is T or g[y][x] in (main, p["side"]):
                    g[y][x] = p["face"]
    for x, y in ((0, 20), (1, 20), (0, 21)):
        put(g, x, y, p["nose"])
    for cy in (23, 26):
        for x in (29, 30, 31):
            put(g, x, cy, p.get("paw", p["body"]))
        put(g, 31, cy, p["line"])


def frames(p):
    return [
        ("walk", front(p, lf="out", ft="step")),
        ("walk_left", front(p, look=-3, ft="step")),
        ("blink", front(p, eyes="closed")),
        ("wave", front(p, rf="up")),
        ("joy", front(p, eyes="happy", lf="up", rf="up", dy=-1, mouth=True)),
        ("jump", front(p, eyes="happy", lf="out", rf="out", ft="tuck", dy=-3)),
        ("sleep", sleep(p)),
        ("surprise", surprise(p)),
        ("slide", slide(p)),
    ]


def png_bytes(pixels, w, h):
    raw = b"".join(b"\x00" + bytes(c for px in row for c in px) for row in pixels)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    return data + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def transparent(g):
    return [[c or (0, 0, 0, 0) for c in row] for row in g]


def write_imageset(root, name, g):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(transparent(g), W, H))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def write_sheet(path, fs):
    s, pad, cols = 8, 16, 3
    cell = W * s
    sw = cols * cell + (cols + 1) * pad
    sh = 3 * cell + 4 * pad
    sheet = [[(240, 238, 234, 255)] * sw for _ in range(sh)]
    for i, (_, g) in enumerate(fs):
        ox = pad + (i % cols) * (cell + pad)
        oy = pad + (i // cols) * (cell + pad)
        for y in range(cell):
            for x in range(cell):
                c = g[y // s][x // s]
                if c is None:
                    c = (255, 255, 255, 255) if ((x // 16) + (y // 16)) % 2 else (232, 230, 226, 255)
                sheet[oy + y][ox + x] = c
    path.write_bytes(png_bytes(sheet, sw, sh))


def main(argv):
    out = Path(argv[0])
    names = argv[1:] or list(SPECIES)
    out.mkdir(parents=True, exist_ok=True)
    for name in names:
        for coat in COATS[name]:
            fs = frames(palette(name, coat))
            for frame, g in fs:
                if out.suffix == ".xcassets":
                    write_imageset(out, f"{name}_{coat}_{frame}", g)
                else:
                    (out / f"{name}_{coat}_{frame}.png").write_bytes(png_bytes(transparent(g), W, H))
            if out.suffix != ".xcassets":
                write_sheet(out / f"{name}_{coat}_sheet.png", fs)


if __name__ == "__main__":
    main(sys.argv[1:])
