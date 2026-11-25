import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "shared"))

from fixed_time import fix_time  # noqa: E402

package = Path(sys.argv[1])
sheet = package / "Sources" / "Features" / "Screens" / "TripResult" / "TripResultSheet.swift"
text = sheet.read_text()
text = text.replace("NavigationStack {", "Group {", 1)
text = text.replace("ScrollView {", "VStack {", 1)
text = text.replace(".scrollBounceBehavior(.basedOnSize)\n", "", 1)
sheet.write_text(text)
fix_time(package)
