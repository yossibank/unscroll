import Foundation

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
