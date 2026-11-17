"""おみやげのご当地の食べ物のドット絵を描く。

食べ物ごとに 48x48 px の絵を、光の当たり方から陰と照りを付けて描き、透明な PNG に書く。
絵の名前は souvenir_<名所>。出力先が .xcassets なら、絵ごとに imageset を作る。
そうでなければ、PNG と並べた見本を書く。描き方の決まりは docs/decisions/landmark.md にある。

    python3 -I scripts/souvenir-art.py <出力先> [名所…]
"""
import json
import struct
import sys
import zlib
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

from artlib.journeys import collect
from artlib.souvenir_kit import N, PAPER, WHITE

FOODS = collect("souvenir", "FOODS")


def sticker(sprite, k):
    size = (N + 2) * k
    out = [[None] * size for _ in range(size)]
    solid = lambda x, y: sprite.get(x, y) is not None
    for y in range(-1, N + 1):
        for x in range(-1, N + 1):
            c = sprite.get(x, y)
            if c is None and any(solid(x + dx, y + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)):
                c = WHITE
            if c is None:
                continue
            for yy in range(k):
                for xx in range(k):
                    out[(y + 1) * k + yy][(x + 1) * k + xx] = c
    return out


def paste(canvas, img, x0, y0):
    for y, row in enumerate(img):
        for x, c in enumerate(row):
            if c is not None and 0 <= y0 + y < len(canvas) and 0 <= x0 + x < len(canvas[0]):
                canvas[y0 + y][x0 + x] = c


def png_bytes(rows):
    h, w = len(rows), len(rows[0])
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in rows)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    return png + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def rgba(rows, background=None):
    clear = (*background, 255) if background else (0, 0, 0, 0)
    return [[(*c, 255) if c else clear for c in row] for row in rows]


def write_imageset(root, name, sprite):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(rgba(sprite.px)))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def write_sheet(path, sprites):
    k, gap, cols = 3, 16, 3
    cell = (N + 2) * k
    rows = (len(sprites) + cols - 1) // cols
    width = cell * cols + gap * (cols + 1)
    canvas = [[PAPER] * width for _ in range(cell * rows + gap * (rows + 1))]
    for i, sprite in enumerate(sprites):
        paste(canvas, sticker(sprite, k), gap + (i % cols) * (cell + gap), gap + (i // cols) * (cell + gap))
    path.write_bytes(png_bytes(rgba(canvas, PAPER)))


def main(argv):
    out = Path(argv[0])
    names = argv[1:] or list(FOODS)
    out.mkdir(parents=True, exist_ok=True)
    sprites = []
    for name in names:
        sprite = FOODS[name]()
        sprites.append(sprite)
        if out.suffix == ".xcassets":
            write_imageset(out, f"souvenir_{name}", sprite)
        else:
            (out / f"souvenir_{name}.png").write_bytes(png_bytes(rgba(sprite.px)))
    if out.suffix != ".xcassets":
        write_sheet(out / "souvenir_sheet.png", sprites)


if __name__ == "__main__":
    main(sys.argv[1:])
