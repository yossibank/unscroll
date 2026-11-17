import shutil
import sys
from pathlib import Path

package = Path(sys.argv[1])
report = package.parent.parent / "UnscrollReport"
target = package / "Sources" / "Features" / "UsageReportCopy"
target.mkdir(parents=True, exist_ok=True)

for name in [
    "TodayUsageParts.swift",
    "TodayUsageReport.swift",
    "TodayUsageView.swift",
]:
    shutil.copy(report / name, target / name)

view = target / "TodayUsageView.swift"
text = view.read_text()
text = text.replace(
    "@State private var tab = Tab.hours",
    "@State private var tab = Tab.allCases[SnapshotTab.index]",
)
text = text.replace("ScrollView {", "VStack(spacing: 0) {")
text = text.replace("        .scrollBounceBehavior(.basedOnSize)\n", "")
view.write_text(text)

(target / "SnapshotTab.swift").write_text(
    "enum SnapshotTab {\n    nonisolated(unsafe) static var index = 0\n}\n"
)
