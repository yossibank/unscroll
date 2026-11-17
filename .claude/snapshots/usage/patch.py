import shutil
import sys
from pathlib import Path

package = Path(sys.argv[1])
report = package.parent.parent / "UnscrollReport"
target = package / "Sources" / "Features" / "UsageReportCopy"
target.mkdir(parents=True, exist_ok=True)

for name in [
    "TodayUsageDetailView.swift",
    "TodayUsageParts.swift",
    "TodayUsageReport.swift",
    "TodayUsageView.swift",
]:
    shutil.copy(report / name, target / name)
