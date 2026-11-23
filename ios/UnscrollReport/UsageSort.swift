import DesignSystem
import SwiftUI

enum UsageSort: Equatable {
    case time
    case pickups
    case perPickup
    case notifications
}

extension UsageSort {
    var tint: Color {
        switch self {
        case .time: Palette.muted
        case .pickups: Palette.sun
        case .perPickup: Palette.sky
        case .notifications: Palette.plum
        }
    }

    var deep: Color {
        switch self {
        case .time: Palette.muted
        case .pickups: Palette.sunDeep
        case .perPickup: Palette.skyDeep
        case .notifications: Palette.plumDeep
        }
    }

    var soft: Color {
        switch self {
        case .time: Palette.paperDeep
        case .pickups: Palette.sunSoft
        case .perPickup: Palette.skySoft
        case .notifications: Palette.plumSoft
        }
    }

    var heading: String {
        switch self {
        case .time: "よく使ったアプリ"
        case .pickups: "手に取った回数が多いアプリ"
        case .perPickup: "1 回が長いアプリ"
        case .notifications: "通知が多いアプリ"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .time: "使った時間で並べる"
        case .pickups: "手に取った回数で並べる"
        case .perPickup: "1 回あたりの時間で並べる"
        case .notifications: "通知の数で並べる"
        }
    }

    func value(of app: AppUsage) -> Double {
        switch self {
        case .time: app.duration
        case .pickups: Double(app.pickups)
        case .perPickup: app.pickups > 0 ? app.duration / Double(app.pickups) : 0
        case .notifications: Double(app.notifications)
        }
    }

    func text(_ value: Double) -> String {
        switch self {
        case .time: TodayUsage.format(value)
        case .pickups: "\(Int(value)) 回"
        case .perPickup: perPickupText(value)
        case .notifications: "\(Int(value)) 件"
        }
    }

    func total(of usage: TodayUsage) -> String? {
        switch self {
        case .time: "合計 \(TodayUsage.format(usage.total))"
        case .pickups: "合計 \(usage.pickups) 回"
        case .perPickup: nil
        case .notifications: "合計 \(usage.notifications) 件"
        }
    }

    private func perPickupText(_ value: Double) -> String {
        guard value > 0 else {
            return "-"
        }

        let minutes = Int(value / 60)

        return minutes < 1 ? "1 回 1 分未満" : "1 回 \(minutes) 分"
    }
}
