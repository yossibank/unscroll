import math


N = 48
OUT = (36, 34, 32)
PAPER = (246, 241, 234)
WHITE = (255, 255, 255)
LIGHT = (-0.5, -0.62, 0.6)
_l = math.sqrt(sum(v * v for v in LIGHT))
LIGHT = tuple(v / _l for v in LIGHT)
_h = (LIGHT[0], LIGHT[1], LIGHT[2] + 1)
_hl = math.sqrt(sum(v * v for v in _h))
HALF = tuple(v / _hl for v in _h)


def noise(x, y, seed=0):
    n = (x * 374761393 + y * 668265263 + seed * 2147483647) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


class Sprite:
    def __init__(self):
        self.px = [[None] * N for _ in range(N)]

    def put(self, x, y, c):
        if 0 <= x < N and 0 <= y < N:
            self.px[y][x] = c

    def get(self, x, y):
        if 0 <= x < N and 0 <= y < N:
            return self.px[y][x]
        return None

    def shape(self, height, ramp, spec=None, power=24, tex=None, border=False, ambient=0.28):
        mask = {}
        for y in range(N):
            for x in range(N):
                h = height(x + 0.5, y + 0.5)
                if h is not None:
                    mask[(x, y)] = h
        if border:
            for (x, y) in list(mask):
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    p = (x + dx, y + dy)
                    if p not in mask and self.get(*p) is not None:
                        self.put(*p, OUT)

        def h_at(x, y, fallback):
            return mask.get((x, y), fallback - 1.5)

        for (x, y), h in mask.items():
            dx = (h_at(x + 1, y, h) - h_at(x - 1, y, h)) / 2
            dy = (h_at(x, y + 1, h) - h_at(x, y - 1, h)) / 2
            n = (-dx, -dy, 1.0)
            ln = math.sqrt(sum(v * v for v in n))
            n = tuple(v / ln for v in n)
            diffuse = max(0.0, sum(n[i] * LIGHT[i] for i in range(3)))
            shade = ambient + (1 - ambient) * diffuse
            index = shade * (len(ramp) - 1)
            index = int(index + (0.5 if noise(x, y, 7) > 0.5 else 0.3))
            index = max(0, min(len(ramp) - 1, index))
            if tex:
                index = max(0, min(len(ramp) - 1, index + tex(x, y, n)))
            c = ramp[index]
            if spec is not None:
                s = max(0.0, sum(n[i] * HALF[i] for i in range(3))) ** power
                if s > 0.55:
                    c = spec
                elif s > 0.3:
                    c = mix(c, spec, 0.5)
            self.put(x, y, c)
        return mask

    def outline(self):
        solid = [[p is not None for p in row] for row in self.px]
        for y in range(N):
            for x in range(N):
                if solid[y][x]:
                    continue
                near = any(
                    0 <= x + dx < N and 0 <= y + dy < N and solid[y + dy][x + dx]
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                )
                if near:
                    self.px[y][x] = OUT
        return self


def ellipsoid(cx, cy, rx, ry, depth=None, taper=0.0):
    depth = depth or min(rx, ry)

    def height(x, y):
        v = (y - cy) / ry
        width = rx * (1 - taper * max(0.0, -v))
        u = (x - cx) / width
        d = u * u + v * v
        if d > 1:
            return None
        return math.sqrt(1 - d) * depth

    return height


def pillow(points, bevel, lift=0.0, clip=None):
    edges = list(zip(points, points[1:] + points[:1]))

    def inside(x, y):
        sign = None
        for (ax, ay), (bx, by) in edges:
            cross = (bx - ax) * (y - ay) - (by - ay) * (x - ax)
            s = cross > 0
            if sign is None:
                sign = s
            elif s != sign:
                return False
        return True

    def dist(x, y):
        best = 1e9
        for (ax, ay), (bx, by) in edges:
            vx, vy = bx - ax, by - ay
            t = max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / (vx * vx + vy * vy)))
            px, py = ax + vx * t, ay + vy * t
            best = min(best, math.hypot(x - px, y - py))
        return best

    def height(x, y):
        if clip and not clip(x, y):
            return None
        if not inside(x, y):
            return None
        d = min(1.0, dist(x, y) / bevel)
        return bevel * math.sqrt(1 - (1 - d) ** 2) + lift

    return height


def steam(s, x0, y0, length, phase):
    for i in range(length):
        x = x0 + 2.2 * math.sin(i * 0.38 + phase)
        fade = i / length
        c = mix((226, 228, 234), (246, 246, 248), fade)
        s.put(int(round(x)), y0 - i, c)
        if i < length - 3:
            s.put(int(round(x)) + 1, y0 - i, mix(c, (255, 255, 255), 0.4))
