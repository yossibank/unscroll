W, H = 228, 150

SEA = (150, 202, 214)
SEA_DEEP = (130, 186, 202)
SHALLOW = (184, 222, 226)
WAVE = (222, 240, 240)
SAND = (238, 222, 176)
LAND_C = (198, 216, 156)
LAND_DARK = (182, 202, 140)
COAST = (122, 140, 96)
LAKE = (140, 196, 214)
LAKE_EDGE = (96, 150, 170)


def project(region, lon, lat):
    lon0, lat0, width, height = region["bounds"]
    return ((lon - lon0) / width * W, (lat0 - lat) / height * H)


def noise(x, y, seed=0):
    n = (x * 374761393 + y * 668265263 + seed * 1442695041) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n ^ (n >> 16)) % 1000 / 1000


def inside(poly, x, y):
    hit = False
    for (x0, y0), (x1, y1) in zip(poly, poly[1:] + poly[:1]):
        if (y0 > y) != (y1 > y) and x < (x1 - x0) * (y - y0) / (y1 - y0) + x0:
            hit = not hit
    return hit


class Canvas:
    def __init__(self):
        self.px = [[(0, 0, 0, 255)] * W for _ in range(H)]

    def put(self, x, y, c):
        if 0 <= x < W and 0 <= y < H:
            self.px[int(y)][int(x)] = (*c, 255)

    def get(self, x, y):
        return self.px[y][x][:3]


def masks(region):
    land_poly = [project(region, *p) for p in region["land"]]
    lake_polys = [[project(region, *p) for p in lake] for lake in region["lakes"]]
    ponds = [project(region, *p) for p in region["ponds"]]
    land = [[inside(land_poly, x + 0.5, y + 0.5) for x in range(W)] for y in range(H)]
    lake = [[False] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            in_lake = any(inside(poly, x + 0.5, y + 0.5) for poly in lake_polys)
            in_pond = any(((x + 0.5 - hx + 1) / 3.6) ** 2 + ((y + 0.5 - hy + 1.5) / 2.4) ** 2 <= 1 for hx, hy in ponds)
            if land[y][x] and (in_lake or in_pond):
                lake[y][x] = True
    return land, lake


def near(mask, x, y, r):
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            if abs(dx) + abs(dy) <= r and 0 <= x + dx < W and 0 <= y + dy < H and mask[y + dy][x + dx]:
                return True
    return False


def sea(cv, land):
    for y in range(H):
        for x in range(W):
            if land[y][x]:
                continue
            if near(land, x, y, 2):
                c = SHALLOW
            else:
                c = SEA_DEEP if y > H * 0.82 and noise(x, y, 2) > 0.35 else SEA
            cv.put(x, y, c)
    for y in range(4, H, 6):
        for x in range((y * 7) % 11, W, 13):
            if all(not near(land, x + k, y, 3) for k in range(3)):
                for k in range(3):
                    cv.put(x + k, y, WAVE)


def ground(cv, land, lake):
    for y in range(H):
        for x in range(W):
            if not land[y][x]:
                continue
            if lake[y][x]:
                edge = any(not lake[y + dy][x + dx] for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                cv.put(x, y, LAKE_EDGE if edge else LAKE)
                continue
            sea_edge = any(
                not land[y + dy][x + dx]
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
                if 0 <= x + dx < W and 0 <= y + dy < H
            )
            if sea_edge:
                cv.put(x, y, COAST)
            elif not near_sea(land, x, y):
                cv.put(x, y, LAND_DARK if noise(x // 3, y // 2, 5) > 0.9 else LAND_C)
            else:
                cv.put(x, y, SAND)


def near_sea(land, x, y):
    for dy in (-2, -1, 0, 1, 2):
        for dx in (-2, -1, 0, 1, 2):
            if abs(dx) + abs(dy) <= 2 and 0 <= x + dx < W and 0 <= y + dy < H and not land[y + dy][x + dx]:
                return True
    return False


def mountain(cv, cx, cy, half, body, light, snow=0):
    height = half + half // 2
    for row in range(height):
        y = cy - height + row + 1
        span = row * half // (height - 1)
        for x in range(cx - span, cx + span + 1):
            c = light if x < cx else body
            if row < snow:
                c = (246, 248, 250) if x <= cx else (212, 222, 232)
            cv.put(x, y, c)


def mountains(cv, region):
    for lon, lat, half in region["mountains"]:
        x, y = project(region, lon, lat)
        snow = 2 if lat >= 35.8 else 0
        mountain(cv, int(x), int(y), half // 2 + 2, (108, 140, 98), (140, 170, 116), snow)


def fuji(cv, region):
    for lon, lat in region["fujis"]:
        x, y = project(region, lon, lat)
        cx, cy = int(x), int(y) + 4
        for row in range(13):
            span = 1 + row * 10 // 12
            for xx in range(cx - span, cx + span + 1):
                c = (120, 146, 188) if xx >= cx else (150, 176, 214)
                if row < 5 or (row == 5 and (xx - cx) % 2 == 0):
                    c = (250, 252, 255) if xx <= cx else (214, 224, 238)
                cv.put(xx, cy - 12 + row, c)


def trees(cv, region):
    for lon, lat in region["trees"]:
        x, y = project(region, lon, lat)
        x, y = int(x), int(y)
        for dx, dy in ((0, -2), (-1, -1), (0, -1), (1, -1), (-1, 0), (0, 0), (1, 0)):
            cv.put(x + dx, y + dy, (96, 140, 86) if dx >= 0 else (118, 160, 98))
        cv.put(x, y + 1, (120, 90, 64))


def frame(cv):
    for x in range(W):
        for y in (0, H - 1):
            cv.put(x, y, shade(cv.get(x, y), 0.85))
    for y in range(H):
        for x in (0, W - 1):
            cv.put(x, y, shade(cv.get(x, y), 0.85))


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c)


def paint(region):
    cv = Canvas()
    land, lake = masks(region)
    sea(cv, land)
    ground(cv, land, lake)
    mountains(cv, region)
    trees(cv, region)
    fuji(cv, region)
    frame(cv)
    return cv
