"""名所の絵はがきのドット絵を描く。

名所ごとに 160x100 px の絵を描き、PNG に書く。絵の名前は landmark_<名所>。
出力先が .xcassets なら、絵ごとに imageset を作る。そうでなければ、PNG と並べた見本を書く。
描き方の決まりは docs/decisions/landmark.md にある。

    python3 -I scripts/landmark-art.py <出力先> [名所…]
"""
import json
import struct
import sys
import zlib
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

from artlib.journeys import collect
from artlib.landmark_kit import H, W

SCENES = collect("landmark", "SCENES")


def png_bytes(rows):
    h, w = len(rows), len(rows[0])
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in rows)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
    return png + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def write_imageset(root, name, rows):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(rows))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def write_sheet(path, scenes):
    k, border, gap = 2, 8, 16
    cw, ch = W * k + border * 2, H * k + border * 2
    cols = 2
    rows = (len(scenes) + cols - 1) // cols
    width = cw * cols + gap * (cols + 1)
    paper, white = (246, 241, 234), (255, 255, 255)
    sheet = [[paper] * width for _ in range(ch * rows + gap * (rows + 1))]
    for i, cv in enumerate(scenes):
        x0 = gap + (i % cols) * (cw + gap)
        y0 = gap + (i // cols) * (ch + gap)
        for y in range(ch):
            for x in range(cw):
                inner = border <= x < cw - border and border <= y < ch - border
                sheet[y0 + y][x0 + x] = cv.px[(y - border) // k][(x - border) // k] if inner else white
    path.write_bytes(png_bytes(sheet))


def main(argv):
    out = Path(argv[0])
    names = argv[1:] or list(SCENES)
    out.mkdir(parents=True, exist_ok=True)
    scenes = []
    for name in names:
        cv = SCENES[name]()
        scenes.append(cv)
        if out.suffix == ".xcassets":
            write_imageset(out, f"landmark_{name}", cv.px)
        else:
            (out / f"landmark_{name}.png").write_bytes(png_bytes(cv.px))
    if out.suffix != ".xcassets":
        write_sheet(out / "landmark_sheet.png", scenes)


if __name__ == "__main__":
    main(sys.argv[1:])
