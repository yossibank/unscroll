import Core
import DeviceActivity
import Foundation
import ManagedSettings
import SwiftUI

struct TodayUsage: Sendable {
    let total: TimeInterval
    let apps: [AppUsage]
    let hours: [TimeInterval]
    let hourPickups: [Int]
    let hourNotifications: [Int]
    let pickups: Int
    let notifications: Int
    let firstPickup: Date?
    let yesterdayTotal: TimeInterval?
    let categories: [CategoryUsage]
}

struct AppUsage: Identifiable, @unchecked Sendable {
    let id: String
    let name: String
    let token: ApplicationToken?
    let duration: TimeInterval
    let pickups: Int
    let notifications: Int
}

struct CategoryUsage: Identifiable, Sendable {
    static let otherName = "ほか"

    let id: String
    let name: String
    let duration: TimeInterval
}

nonisolated struct TodayUsageReport<Content: View>: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context
    let content: (TodayUsage) -> Content

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> TodayUsage {
        let calendar = Calendar.current
        let now = Date.now
        let todayStart = calendar.startOfDay(for: now)
        let sameTimeYesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            .addingTimeInterval(-86400)

        var durations: [String: TimeInterval] = [:]
        var tokens: [String: ApplicationToken] = [:]
        var categories: [String: TimeInterval] = [:]
        var appPickups: [String: Int] = [:]
        var appNotifications: [String: Int] = [:]
        var hours = Array(repeating: TimeInterval(0), count: 24)
        var hourPickups = Array(repeating: 0, count: 24)
        var hourNotifications = Array(repeating: 0, count: 24)
        var yesterdayTotal: TimeInterval?
        var pickups = 0
        var notifications = 0
        var firstPickup: Date?

        for await device in data {
            for await segment in device.activitySegments {
                let start = segment.dateInterval.start

                guard start >= todayStart else {
                    let length = max(segment.dateInterval.duration, 1)
                    let before = min(max(sameTimeYesterday.timeIntervalSince(start), 0), length)
                    let share = segment.totalActivityDuration * before / length

                    yesterdayTotal = (yesterdayTotal ?? 0) + share

                    continue
                }

                let hour = calendar.component(.hour, from: start)

                hours[hour] += segment.totalActivityDuration
                pickups += segment.totalPickupsWithoutApplicationActivity
                hourPickups[hour] += segment.totalPickupsWithoutApplicationActivity

                if let pickup = segment.firstPickup {
                    firstPickup = min(firstPickup ?? pickup, pickup)
                }

                for await category in segment.categories {
                    let categoryName = category.category.localizedDisplayName ?? CategoryUsage
                        .otherName

                    categories[categoryName, default: 0] += category.totalActivityDuration

                    for await app in category.applications {
                        let application = app.application
                        let name = application.localizedDisplayName ?? application
                            .bundleIdentifier ?? "不明"

                        durations[name, default: 0] += app.totalActivityDuration
                        tokens[name] = tokens[name] ?? application.token
                        appPickups[name, default: 0] += app.numberOfPickups
                        appNotifications[name, default: 0] += app.numberOfNotifications
                        pickups += app.numberOfPickups
                        notifications += app.numberOfNotifications
                        hourPickups[hour] += app.numberOfPickups
                        hourNotifications[hour] += app.numberOfNotifications
                    }
                }
            }
        }

        let apps = durations
            .map {
                AppUsage(
                    id: $0.key,
                    name: $0.key,
                    token: tokens[$0.key],
                    duration: $0.value,
                    pickups: appPickups[$0.key] ?? 0,
                    notifications: appNotifications[$0.key] ?? 0
                )
            }
            .sorted { $0.duration > $1.duration }
        let kinds = categories
            .filter { $0.value > 0 }
            .map { CategoryUsage(id: $0.key, name: $0.key, duration: $0.value) }
            .sorted { $0.duration > $1.duration }

        return TodayUsage(
            total: hours.reduce(0, +),
            apps: apps,
            hours: hours,
            hourPickups: hourPickups,
            hourNotifications: hourNotifications,
            pickups: pickups,
            notifications: notifications,
            firstPickup: firstPickup,
            yesterdayTotal: yesterdayTotal,
            categories: kinds
        )
    }
}
