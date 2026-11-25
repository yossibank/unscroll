import re
from pathlib import Path

FIXED = "Date(timeIntervalSince1970: 1_791_000_000)"
TIMELINE = re.compile(r"TimelineView\([^{\n]*\) \{ context in")
NOW = re.compile(r"\bDate\.now\b|(?<![\w)\]])\.now\b")
STAND_IN = f"""import SwiftUI

struct SnapshotTimelineContext {{
    let date = {FIXED}
}}

struct SnapshotTimeline<Content: View>: View {{
    let content: (SnapshotTimelineContext) -> Content

    init(@ViewBuilder content: @escaping (SnapshotTimelineContext) -> Content) {{
        self.content = content
    }}

    var body: some View {{
        content(SnapshotTimelineContext())
    }}
}}
"""


def fix_time(package):
    """描く用の写しで、画面の部品が読む今の時刻を、決まった時刻に置き換える。"""
    for module in ["DesignSystem", "Features"]:
        root = Path(package) / "Sources" / module
        for path in sorted(root.rglob("*.swift")):
            text = path.read_text()
            fixed = NOW.sub(FIXED, TIMELINE.sub("SnapshotTimeline { context in", text))
            if fixed != text:
                path.write_text(fixed)
        (root / "SnapshotTimeline.swift").write_text(STAND_IN)
