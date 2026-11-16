import math


W, H = 320, 210
TAU = math.tau
HAZE = (216, 234, 240)
LAYERS = ("far", "mid", "near")


def noise(x, y, seed=0):
    x %= W
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def wave(x, *terms):
    return sum(amp * math.sin(TAU * cycles * x / W + phase) for amp, cycles, phase in terms)


class Layer:
    def __init__(self):
        self.px = [[None] * W for _ in range(H)]

    def put(self, x, y, c):
        if 0 <= y < H:
            self.px[y][int(x) % W] = c

    def get(self, x, y):
        if 0 <= y < H:
            return self.px[y][int(x) % W]
        return None


def ridge(layer, base, terms, color, until, haze=0.0):
    top_color = mix(color, (255, 255, 255), 0.15)
    for x in range(W):
        top = int(base - wave(x, *terms))
        for y in range(top, until):
            c = top_color if y == top else color
            layer.put(x, y, mix(c, HAZE, haze))


def grass(layer, top, bottom, color, seed=3):
    light, dark = mix(color, (240, 236, 190), 0.2), shade(color, 0.8)
    for y in range(top, bottom):
        for x in range(W):
            layer.put(x, y, light if y == top else dark if noise(x, y, seed) < 0.15 else color)


def cobble(layer, top, bottom, light=(152, 146, 132), dark=(132, 126, 114), joint=(92, 88, 80)):
    for y in range(top, bottom):
        row = (y - top) // 3
        for x in range(W):
            stone = light if noise((x + row * 2) // 5, row, 4) > 0.5 else dark
            layer.put(x, y, joint if (y - top) % 3 == 0 or (x + row * 2) % 5 == 0 else stone)


def dirt(layer, top, bottom, base=(204, 178, 132)):
    edge, light = shade(base, 0.86), mix(base, (255, 240, 210), 0.3)
    for y in range(top, bottom):
        for x in range(W):
            r = noise(x, y, 7)
            layer.put(x, y, edge if y in (top, bottom - 1) else light if r > 0.9 else base)


def cedar(layer, x0, base, h, color=(40, 78, 58)):
    dark, light = shade(color, 0.7), mix(color, (160, 200, 140), 0.3)
    for y in range(base - h, base + 1):
        t = (y - (base - h)) / h
        half = 1 + t * h * 0.22
        for x in range(int(x0 - half), int(x0 + half) + 1):
            c = color
            if (y - base) % 4 == 0 and abs(x - x0) > half * 0.5:
                c = dark
            elif x < x0 - half * 0.3 and noise(x, y, 2) > 0.6:
                c = light
            layer.put(x, y, c)
    for y in range(base, base + 4):
        layer.put(x0, y, (96, 66, 50))


def pine(layer, x0, base, height, needle=(44, 92, 70)):
    trunk, trunk_dark = (110, 78, 60), (78, 54, 44)
    needle_dark, needle_light = shade(needle, 0.7), mix(needle, (180, 220, 150), 0.35)
    for i in range(height):
        lean = int(math.sin(i * 0.12) * 3)
        layer.put(x0 + lean, base - i, trunk)
        layer.put(x0 + lean + 1, base - i, trunk_dark)
    s = height / 40
    for frac, w, h, shift in ((1.0, 8, 4, 0), (0.8, 11, 4, 4), (0.6, 9, 4, -4), (0.42, 6, 3, 3)):
        w, h = max(3, int(w * s)), max(2, int(h * s + 0.5))
        py = base - int(height * frac) + h
        pcx = x0 + int(math.sin(height * frac * 0.12) * 3) + shift
        for y in range(py - h, py + 1):
            for x in range(pcx - w, pcx + w + 1):
                dx, dy = (x - pcx) / w, (py - y) / h
                if dy >= 0 and dx * dx + dy * dy * 1.3 <= 1 + 0.12 * math.sin(x * 1.9):
                    if dy > 0.7 or (dy > 0.45 and (x + y) % 3 == 0):
                        c = needle_light
                    elif dy < 0.2:
                        c = needle_dark
                    else:
                        c = needle
                    layer.put(x, y, c)


def maple(layer, cx, cy, r):
    for y in range(cy - r, cy + r):
        for x in range(cx - r - 2, cx + r + 3):
            if ((x - cx) / (r + 2)) ** 2 + ((y - cy) / r) ** 2 > 0.88 + 0.25 * noise(x, y, 6):
                continue
            n = noise(x // 2, y // 2, cx)
            c = (226, 88, 50) if n < 0.45 else (246, 146, 60) if n < 0.75 else (186, 48, 40)
            if y < cy - r * 0.4 and n > 0.6:
                c = (255, 196, 96)
            layer.put(x, y, c)
    for y in range(cy + r - 2, cy + r + 8):
        layer.put(cx, y, (92, 62, 48))
        layer.put(cx + 1, y, (70, 48, 38))


def water(layer, top, bottom, deep, light, seed=1):
    for y in range(top, bottom):
        t = (y - top) / max(1, bottom - top)
        base = mix(light, deep, t)
        for x in range(W):
            c = base
            glint = (x + (y * 13) % 17) % 23 < 3 and y % 4 == 1 and noise(x // 23, y, seed) > 0.5
            if glint:
                c = mix(c, (255, 255, 255), 0.45)
            layer.put(x, y, c)
    for x in range(W):
        layer.put(x, top, mix(light, (255, 255, 255), 0.4))


def fuji(layer, cx, peak, base, half, snow):
    rock, rock_dark = (98, 120, 158), (76, 94, 130)
    snow_lit, snow_dark = (250, 250, 248), (202, 214, 232)
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
            layer.put(x, y, mix(c, HAZE, 0.12))


def machiya(layer, base, roof=(58, 62, 72)):
    x, i = 0, 0
    widths = [20, 24, 18, 22, 26, 20, 24, 18, 22, 26, 20, 24, 20, 18, 18]
    for w in widths:
        h = 18 + int(noise(i, 1, 5) * 6)
        top = base - h
        wood, lattice = (120, 80, 56), (88, 58, 40)
        for y in range(top, base):
            for xx in range(x, x + w):
                c = wood
                if y > top + 8 and (xx - x) % 2 == 0:
                    c = lattice
                if top + 3 < y < top + 8 and 2 < xx - x < w - 3:
                    c = (226, 218, 200) if (xx - x) % 3 else lattice
                layer.put(xx, y, c)
        for k in range(5):
            for xx in range(x - 2 + k // 2, x + w + 2 - k // 2):
                layer.put(xx, top - k, roof if k < 4 else mix(roof, (255, 255, 255), 0.25))
        for xx in range(x - 2, x + w + 2):
            layer.put(xx, top + 8, roof)
            layer.put(xx, top + 9, mix(roof, (255, 255, 255), 0.25))
        noren = (40, 60, 110) if i % 2 else (150, 40, 40)
        for y in range(top + 10, top + 15):
            for xx in range(x + w // 2 - 3, x + w // 2 + 3):
                if not (y > top + 12 and xx % 2):
                    layer.put(xx, y, noren)
        for y in range(top + 10, top + 14):
            for xx in (x + w - 3, x + w - 2):
                layer.put(xx, y, (240, 214, 150))
        x += w
        i += 1


def roofs(layer, base, rows):
    tile, tile_light, wall = (64, 68, 78), (104, 110, 120), (220, 212, 196)
    for row in range(rows):
        y0 = base - row * 9
        offset = row * 13
        for x in range(0, W, 26):
            for k in range(8):
                for xx in range(x + offset - 13 + k, x + offset + 13 - k):
                    c = tile_light if k == 7 else tile
                    layer.put(xx, y0 - k, c)
            for y in range(y0 + 1, y0 + 4):
                for xx in range(x + offset - 10, x + offset + 10):
                    layer.put(xx, y, wall if (xx + y) % 5 else (150, 120, 90))
