import Core
import DeviceActivity
import SwiftUI

public struct UsageReportView: View {
    public init() {}

    public var body: some View {
        DeviceActivityReport(reportContext, filter: todayFilter)
    }
}

private extension UsageReportView {
    var reportContext: DeviceActivityReport.Context {
        DeviceActivityReport.Context(ScreenTimeShared.reportContextName)
    }

    var todayFilter: DeviceActivityFilter {
        let today = Calendar.current.dateInterval(of: .day, for: .now) ?? DateInterval()

        return DeviceActivityFilter(
            segment: .daily(during: today),
            users: .all,
            devices: .init([.iPhone])
        )
    }
}
