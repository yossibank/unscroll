import math


W, H = 160, 100
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
OUT = (36, 34, 32)

SKIES = {
    "morning": [(120, 168, 214), (172, 198, 228), (230, 210, 210), (252, 222, 186)],
    "day": [(88, 154, 220), (128, 184, 234), (172, 210, 240), (216, 234, 240)],
    "evening": [(64, 64, 128), (146, 92, 140), (230, 126, 104), (252, 190, 116)],
    "night": [(10, 14, 36), (18, 26, 60), (30, 42, 86), (46, 58, 104)],
}
TINTS = {
    "morning": ((255, 220, 200), 0.12, 1.0),
    "day": ((255, 255, 255), 0.0, 1.0),
    "evening": ((255, 150, 110), 0.22, 0.88),
    "night": ((30, 44, 100), 0.55, 0.55),
}


def noise(x, y, seed=0):
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


class Canvas:
    def __init__(self, time):
        self.time = time
        self.px = [[(0, 0, 0)] * W for _ in range(H)]

    def tint(self, c):
        color, amount, light = TINTS[self.time]
        return shade(mix(c, color, amount), light)

    def put(self, x, y, c, tint=True):
        if 0 <= x < W and 0 <= y < H:
            self.px[y][x] = self.tint(c) if tint else c

    def get(self, x, y):
        return self.px[min(max(y, 0), H - 1)][min(max(x, 0), W - 1)]


def sky(cv, horizon):
    stops = SKIES[cv.time]
    for y in range(horizon):
        t = y / max(1, horizon - 1) * (len(stops) - 1)
        i = min(int(t), len(stops) - 2)
        q = (t - i) * 4
        k = int(q)
        for x in range(W):
            level = k + (1 if (q - k) * 16 > BAYER[y % 4][x % 4] + 0.5 else 0)
            cv.put(x, y, mix(stops[i], stops[i + 1], min(level, 4) / 4), tint=False)
    if cv.time == "night":
        for n in range(46):
            x, y = int(noise(n, 1, 5) * W), int(noise(n, 2, 5) * horizon * 0.7)
            cv.put(x, y, (240, 236, 210) if n % 3 else (170, 186, 230), tint=False)


def disc(cv, cx, cy, r, color, glow=None):
    for y in range(int(cy - r * 2), int(cy + r * 2) + 1):
        for x in range(int(cx - r * 2), int(cx + r * 2) + 1):
            d = math.hypot(x - cx, y - cy)
            if d <= r:
                cv.put(x, y, color, tint=False)
            elif glow and d <= r * 1.8 and (x + y) % 2 == 0:
                cv.put(x, y, mix(cv.get(x, y), glow, 0.5), tint=False)


def moon(cv, cx, cy):
    for y in range(-6, 7):
        for x in range(-6, 7):
            if x * x + y * y <= 36 and (x + 3) ** 2 + (y - 1) ** 2 > 22:
                cv.put(cx + x, cy + y, (252, 240, 190), tint=False)


def cloud(cv, cx, cy, size):
    light = {"day": (252, 252, 250), "morning": (255, 238, 228), "evening": (255, 186, 150), "night": (60, 70, 110)}[cv.time]
    dark = mix(light, SKIES[cv.time][1], 0.45)
    blobs = [(0, 0, size, size * 0.55), (-size * 0.85, size * 0.18, size * 0.6, size * 0.4), (size * 0.9, size * 0.22, size * 0.62, size * 0.38)]
    for y in range(int(cy - size), int(cy + size)):
        for x in range(int(cx - size * 2), int(cx + size * 2)):
            if y > cy + size * 0.42:
                continue
            if any(((x - cx - bx) / rx) ** 2 + ((y - cy - by) / ry) ** 2 <= 1 for bx, by, rx, ry in blobs):
                cv.put(x, y, dark if y > cy + size * 0.18 else light, tint=False)


def profile(cv, top_fn, bottom, color_fn, x0=0, x1=W):
    for x in range(x0, x1):
        top = top_fn(x)
        if top is None:
            continue
        for y in range(int(top), bottom):
            c = color_fn(x, y, y - int(top))
            if c is not None:
                cv.put(x, y, c)


def forest_color(base, top_light=True):
    light = mix(base, (210, 230, 170), 0.22)
    dark = mix(base, (10, 24, 20), 0.35)

    def color(x, y, depth):
        r = noise(x // 2, y // 2, 3)
        if depth == 0 and top_light:
            return light
        if r < 0.22:
            return dark
        if r > 0.86:
            return light
        return base

    return color


def fuji(cv, cx, peak, base, half, snow, rock=(98, 120, 158), haze=0.0):
    rock_dark = shade(rock, 0.78)
    snow_lit, snow_dark = (250, 250, 248), (202, 214, 232)
    sky_col = SKIES[cv.time][-1]
    for y in range(peak, base):
        t = (y - peak) / (base - peak)
        hw = 2 + (half - 2) * t ** 1.45
        for x in range(int(cx - hw), int(cx + hw) + 1):
            right = x > cx + (y - peak) * 0.16
            line = peak + snow + 2 * math.sin(x * 1.7) + (5 if x % 5 == 0 else 0) + (2 if x % 3 == 0 else 0)
            if y < line:
                c = snow_dark if right else snow_lit
            else:
                c = rock_dark if right else rock
                if x % 7 == 3 and y < line + 5 + (x * 3) % 5:
                    c = mix(c, snow_dark, 0.5)
            cv.put(x, y, mix(c, sky_col, haze))


def water(cv, top, bottom, deep, glints=True):
    for y in range(top, bottom):
        depth = (y - top) / max(1, bottom - top)
        offset = int(round(math.sin(y * 1.3) * (1 + depth)))
        src = cv.get(W // 2, 0)
        for x in range(W):
            src = cv.get(x + offset, 2 * top - y - 1)
            c = mix(src, cv.tint(deep), 0.4 + depth * 0.35)
            if glints and (x + (y * 13) % 17) % 23 < 3 and y % 4 == 1 and (x // 23 + y) % 3 == 0:
                c = mix(c, (255, 255, 255), 0.3)
            cv.put(x, y, c, tint=False)
    for x in range(W):
        cv.put(x, top, mix(cv.get(x, top), (255, 255, 255), 0.22), tint=False)


def draw(cv, layer, tint=True):
    for (x, y), c in layer.items():
        cv.put(x, y, c, tint=tint)


def reflect(cv, layer, axis, top, bottom, deep, strength=0.55):
    for (x, y), c in layer.items():
        ry = 2 * axis - y
        if top < ry < bottom and y <= axis:
            wobble = int(round(math.sin(ry * 1.3)))
            under = cv.get(x + wobble, ry)
            cv.put(x + wobble, ry, mix(under, mix(cv.tint(c), cv.tint(deep), 0.45), strength), tint=False)


def torii(cx, top, bottom, w, red=(214, 62, 46)):
    layer = {}
    dark, black = shade(red, 0.72), (44, 36, 36)
    pw = max(2, w // 6)
    for x in range(cx - w - 3, cx + w + 4):
        dx = abs(x - cx)
        lift = 1 if dx > w else 0
        layer[(x, top - lift)] = black
        layer[(x, top + 1 - lift)] = red if x < cx + w // 2 else dark
        if dx <= w:
            layer[(x, top + 2)] = dark
    nuki = top + max(4, (bottom - top) // 4)
    for x in range(cx - w + 1, cx + w):
        layer[(x, nuki)] = red
        if w > 8:
            layer[(x, nuki + 1)] = dark
    for y in range(top + 3, nuki):
        layer[(cx, y)] = red
    for side in (-1, 1):
        px = cx + side * (w - pw - 1)
        for y in range(top + 3, bottom + 1):
            for k in range(pw):
                layer[(px + k, y)] = red if k < pw - 1 else dark
    return layer


def pine(cv, x0, base, height, flip=False, needle=(44, 92, 70)):
    trunk, trunk_dark = (110, 78, 60), (78, 54, 44)
    needle_dark, needle_light = shade(needle, 0.7), mix(needle, (180, 220, 150), 0.35)
    sign = -1 if flip else 1
    for i in range(height):
        lean = int(math.sin(i * 0.12) * 3) * sign
        cv.put(x0 + lean, base - i, trunk)
        cv.put(x0 + lean + 1, base - i, trunk_dark)
    scale = height / 40
    for frac, w, h, shift in ((1.0, 8, 4, 0), (0.8, 11, 4, 4), (0.6, 9, 4, -4), (0.42, 6, 3, 3)):
        w = max(3, int(w * scale))
        h = max(2, int(h * scale + 0.5))
        py = base - int(height * frac) + h
        pcx = x0 + int(math.sin(height * frac * 0.12) * 3) * sign + shift * sign
        for y in range(py - h, py + 1):
            for x in range(pcx - w, pcx + w + 1):
                dx, dy = (x - pcx) / w, (py - y) / h
                if dy >= 0 and dx * dx + dy * dy * 1.3 <= 1 + 0.12 * math.sin(x * 1.9):
                    c = needle
                    if dy > 0.7 or (dy > 0.45 and (x + y) % 3 == 0):
                        c = needle_light
                    elif dy < 0.2:
                        c = needle_dark
                    cv.put(x, y, c)


def ground(cv, top, color, seed=3, until=H):
    dark, light = shade(color, 0.8), mix(color, (240, 236, 190), 0.2)
    for y in range(top, until):
        for x in range(W):
            r = noise(x, y, seed)
            cv.put(x, y, light if y == top else dark if r < 0.15 else color)
