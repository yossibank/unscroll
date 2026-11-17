"""旅の途中の景色のドット絵を描く。

次に向かう名所ごとに、遠景・中景・近景の 3 枚の層を 320x210 px の透明な PNG に描く。
どの層も横につなげて流せるように、左右の端をそろえて描く。空と時刻の光の色はアプリが描く。
絵の名前は trip_<名所>_<層>。出力先が .xcassets なら、絵ごとに imageset を作る。
そうでなければ、層を重ねた見本を書く。描き方の決まりは docs/decisions/landmark.md にある。

    python3 -I scripts/trip-art.py <出力先> [名所…]
"""
import json
import struct
import sys
import zlib
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

from artlib.journeys import collect
from artlib.trip_kit import H, LAYERS, W, mix

SCENES = collect("trip", "SCENES")


def png_bytes(rows):
    h, w = len(rows), len(rows[0])
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in rows)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    return png + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def rgba(layer):
    return [[(*c, 255) if c else (0, 0, 0, 0) for c in row] for row in layer.px]


def write_imageset(root, name, layer):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(rgba(layer)))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def flatten(layers):
    sky = [(128, 184, 234), (216, 234, 240)]
    rows = [[mix(sky[0], sky[1], y / H)] * W for y in range(H)]
    for layer in layers:
        for y in range(H):
            for x in range(W):
                if layer.px[y][x]:
                    rows[y][x] = layer.px[y][x]
    return rows


def write_sheet(path, scenes):
    gap = 12
    width = W + gap * 2
    sheet = [[(246, 241, 234)] * width for _ in range(gap)]
    for layers in scenes:
        for row in flatten(layers):
            sheet.append([(246, 241, 234)] * gap + row + [(246, 241, 234)] * gap)
        sheet += [[(246, 241, 234)] * width for _ in range(gap)]
    path.write_bytes(png_bytes([[(*c, 255) for c in row] for row in sheet]))


def main(argv):
    out = Path(argv[0])
    names = argv[1:] or list(SCENES)
    out.mkdir(parents=True, exist_ok=True)
    scenes = []
    for name in names:
        layers = SCENES[name]()
        scenes.append(layers)
        for kind, layer in zip(LAYERS, layers):
            if out.suffix == ".xcassets":
                write_imageset(out, f"trip_{name}_{kind}", layer)
            else:
                (out / f"trip_{name}_{kind}.png").write_bytes(png_bytes(rgba(layer)))
    if out.suffix != ".xcassets":
        write_sheet(out / "trip_sheet.png", scenes)


if __name__ == "__main__":
    main(sys.argv[1:])
