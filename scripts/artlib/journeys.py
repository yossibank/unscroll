import importlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
JOURNEYS = ROOT / "journeys"


def collect(kind, attr):
    sys.path.insert(0, str(ROOT))
    merged = {}
    for folder in sorted(p for p in JOURNEYS.iterdir() if (p / f"{kind}.py").exists()):
        module = importlib.import_module(f"journeys.{folder.name}.{kind}")
        for name, draw in getattr(module, attr).items():
            if name in merged:
                raise SystemExit(f"{kind}: {name} が重なっています ({folder.name})")
            merged[name] = draw
    return merged
