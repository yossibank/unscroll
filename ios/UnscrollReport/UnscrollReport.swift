import Core
import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct UnscrollReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TodayUsageReport(context: .init(UsageSort.time.reportContextName)) { usage in
            TodayUsageView(usage: usage, sort: .time)
        }

        TodayUsageReport(context: .init(UsageSort.pickups.reportContextName)) { usage in
            TodayUsageView(usage: usage, sort: .pickups)
        }

        TodayUsageReport(context: .init(UsageSort.perPickup.reportContextName)) { usage in
            TodayUsageView(usage: usage, sort: .perPickup)
        }

        TodayUsageReport(context: .init(UsageSort.notifications.reportContextName)) { usage in
            TodayUsageView(usage: usage, sort: .notifications)
        }
    }
}
