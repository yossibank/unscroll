import sys
from pathlib import Path

package = Path(sys.argv[1])
tags = package / "Sources" / "Features" / "Shared" / "ScreenTime" / "AppSetTags.swift"
text = tags.read_text()
text = text.replace("ScrollView(.horizontal) {", "VStack(alignment: .leading) {")
text = text.replace("        .scrollIndicators(.hidden)\n", "")
text = text.replace("        .scrollClipDisabled()\n", "")
tags.write_text(text)
