import Core
import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct UnscrollReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TodayUsageReport(context: .init(ScreenTimeShared.reportContextName)) { usage in
            TodayUsageView(usage: usage)
        }
    }
}
