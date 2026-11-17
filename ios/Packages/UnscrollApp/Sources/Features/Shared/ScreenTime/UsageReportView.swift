import Core
import DeviceActivity
import SwiftUI

public struct UsageReportView: View {
    public init() {}

    public var body: some View {
        DeviceActivityReport(reportContext, filter: filter)
    }
}

private extension UsageReportView {
    var reportContext: DeviceActivityReport.Context {
        DeviceActivityReport.Context(ScreenTimeShared.reportContextName)
    }

    var filter: DeviceActivityFilter {
        let calendar = Calendar.current
        let today = calendar.dateInterval(of: .day, for: .now) ?? DateInterval()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today.start) ?? today.start
        let interval = DateInterval(start: yesterday, end: today.end)

        return DeviceActivityFilter(
            segment: .hourly(during: interval),
            users: .all,
            devices: .init([.iPhone])
        )
    }
}
