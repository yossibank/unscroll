import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "shared"))

from fixed_time import fix_time  # noqa: E402

fix_time(Path(sys.argv[1]))
