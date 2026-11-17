import Core
import DeviceActivity
import SwiftUI

public struct UsageReportView: View {
    private let isDetailed: Bool

    public init(isDetailed: Bool = false) {
        self.isDetailed = isDetailed
    }

    public var body: some View {
        DeviceActivityReport(reportContext, filter: filter)
    }
}

private extension UsageReportView {
    var reportContext: DeviceActivityReport.Context {
        DeviceActivityReport.Context(
            isDetailed
                ? ScreenTimeShared.reportDetailContextName
                : ScreenTimeShared.reportContextName
        )
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
