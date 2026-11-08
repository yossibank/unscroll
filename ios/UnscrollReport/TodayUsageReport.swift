import Core
import DeviceActivity
import Foundation
import ManagedSettings
import SwiftUI

struct TodayUsage: Sendable {
    let total: TimeInterval
    let apps: [AppUsage]
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
        var durations: [String: TimeInterval] = [:]
        var tokens: [String: ApplicationToken] = [:]

        for await device in data {
            for await segment in device.activitySegments {
                for await category in segment.categories {
                    for await app in category.applications {
                        let application = app.application
                        let name = application.localizedDisplayName ?? application
                            .bundleIdentifier ?? "不明"
                        durations[name, default: 0] += app.totalActivityDuration
                        tokens[name] = tokens[name] ?? application.token
                    }
                }
            }
        }

        let apps = durations
            .map { AppUsage(id: $0.key, name: $0.key, token: tokens[$0.key], duration: $0.value) }
            .sorted { $0.duration > $1.duration }

        return TodayUsage(total: apps.reduce(0) { $0 + $1.duration }, apps: apps)
    }
}
