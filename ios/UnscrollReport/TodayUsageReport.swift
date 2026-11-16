import Core
import DeviceActivity
import Foundation
import ManagedSettings
import SwiftUI

struct TodayUsage: Sendable {
    let total: TimeInterval
    let apps: [AppUsage]
    let hours: [TimeInterval]
    let pickups: Int
    let notifications: Int
    let firstPickup: Date?
}

struct AppUsage: Identifiable, @unchecked Sendable {
    let id: String
    let name: String
    let token: ApplicationToken?
    let duration: TimeInterval
}

nonisolated struct TodayUsageReport: DeviceActivityReportScene {
    let context = DeviceActivityReport.Context(ScreenTimeShared.reportContextName)
    let content: (TodayUsage) -> TodayUsageView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> TodayUsage {
        let calendar = Calendar.current

        var durations: [String: TimeInterval] = [:]
        var tokens: [String: ApplicationToken] = [:]
        var hours = Array(repeating: TimeInterval(0), count: 24)
        var pickups = 0
        var notifications = 0
        var firstPickup: Date?

        for await device in data {
            for await segment in device.activitySegments {
                let hour = calendar.component(.hour, from: segment.dateInterval.start)

                hours[hour] += segment.totalActivityDuration
                pickups += segment.totalPickupsWithoutApplicationActivity

                if let pickup = segment.firstPickup {
                    firstPickup = min(firstPickup ?? pickup, pickup)
                }

                for await category in segment.categories {
                    for await app in category.applications {
                        let application = app.application
                        let name = application.localizedDisplayName ?? application
                            .bundleIdentifier ?? "不明"

                        durations[name, default: 0] += app.totalActivityDuration
                        tokens[name] = tokens[name] ?? application.token
                        pickups += app.numberOfPickups
                        notifications += app.numberOfNotifications
                    }
                }
            }
        }

        let apps = durations
            .map { AppUsage(id: $0.key, name: $0.key, token: tokens[$0.key], duration: $0.value) }
            .sorted { $0.duration > $1.duration }

        return TodayUsage(
            total: apps.reduce(0) { $0 + $1.duration },
            apps: apps,
            hours: hours,
            pickups: pickups,
            notifications: notifications,
            firstPickup: firstPickup
        )
    }
}
