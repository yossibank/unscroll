import sys
from pathlib import Path

package = Path(sys.argv[1])
sheet = package / "Sources" / "Features" / "Screens" / "TripResult" / "TripResultSheet.swift"
text = sheet.read_text()
text = text.replace("NavigationStack {", "Group {", 1)
text = text.replace("ScrollView {", "VStack {", 1)
text = text.replace(".scrollBounceBehavior(.basedOnSize)\n", "", 1)
sheet.write_text(text)
