import shutil
import sys
from pathlib import Path

package = Path(sys.argv[1])
report = package.parent.parent / "UnscrollReport"
target = package / "Sources" / "Features" / "UsageReportCopy"
target.mkdir(parents=True, exist_ok=True)

for path in sorted(report.glob("*.swift")):
    if path.name not in {"UnscrollReport.swift", "TodayUsageReport.swift"}:
        shutil.copy(path, target / path.name)
