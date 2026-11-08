import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct UnscrollReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TodayUsageReport { usage in
            TodayUsageView(usage: usage)
        }
    }
}
