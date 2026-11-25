import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "shared"))

from fixed_time import fix_time  # noqa: E402

package = Path(sys.argv[1])
tags = package / "Sources" / "Features" / "Shared" / "ScreenTime" / "AppSetTags.swift"
text = tags.read_text()
text = text.replace("ScrollView(.horizontal) {", "VStack(alignment: .leading) {")
text = text.replace("        .scrollIndicators(.hidden)\n", "")
text = text.replace("        .scrollClipDisabled()\n", "")
tags.write_text(text)
fix_time(package)
