import sys
from pathlib import Path

package = Path(sys.argv[1])
sheet = package / "Sources" / "Features" / "Screens" / "Tabs" / "Map" / "JourneyPickerSheet.swift"
source = sheet.read_text()

source = source.replace("ScrollView(.horizontal) {", "HStack(spacing: 0) {")
source = source.replace("ScrollView {", "VStack {")

sheet.write_text(source)
