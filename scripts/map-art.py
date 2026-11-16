"""地図の土台のドット絵を描く。

海・浅瀬・陸・山・富士山・琵琶湖・浜名湖を、228x150 px の PNG に描く。
道・名所の印・相棒は進み具合で変わるので、アプリが上に重ねる。
経度と緯度から点への写し方は JourneyMapGeometry+<道のり>.swift の投影とそろえる。
道のりごとの地域は scripts/journeys/<道のり>/map.py にあり、絵の名前は map_<道のり>。描き方の決まりは docs/decisions/landmark.md にある。
出力先が .xcassets なら imageset を作り、そうでなければ 3 倍に広げた見本も書く。

    python3 -I scripts/map-art.py <出力先>
"""
import json
import struct
import sys
import zlib
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))

from artlib.journeys import collect

MAPS = collect("map", "MAPS")


def png_bytes(px):
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in px)

    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", len(px[0]), len(px), 8, 6, 0, 0, 0)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header)
    return data + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def write_imageset(root, name, px):
    folder = root / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / f"{name}.png").write_bytes(png_bytes(px))
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def main(argv):
    out = Path(argv[0])
    out.mkdir(parents=True, exist_ok=True)
    for name, draw in MAPS.items():
        cv = draw()
        if out.suffix == ".xcassets":
            contents = out / "Contents.json"
            if not contents.exists():
                contents.write_text(json.dumps({"info": {"author": "xcode", "version": 1}}, indent=2) + "\n")
            write_imageset(out, name, cv.px)
            continue
        (out / f"{name}.png").write_bytes(png_bytes(cv.px))
        big = [[p for p in row for _ in range(3)] for row in cv.px for _ in range(3)]
        (out / f"{name}_preview.png").write_bytes(png_bytes(big))


if __name__ == "__main__":
    main(sys.argv[1:])
