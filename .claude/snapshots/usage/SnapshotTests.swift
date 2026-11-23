import Core
import DesignSystem
@testable import Features
import SwiftUI
import Testing
import UIKit

@MainActor
struct SnapshotTests {
    @Test
    func render() throws {
        for item in Self.cases() {
            let view = item.view()
                .padding(16)
                .frame(width: item.size.width, height: item.size.height, alignment: item.alignment)
                .clipped()
                .background(Color.white)
                .environment(\.colorScheme, .light)

            try Self.write(view, to: "\(item.name).png")
        }
    }
}

extension SnapshotTests {
    struct Case {
        let name: String
        let size: CGSize

        var alignment: Alignment = .top

        let view: () -> AnyView
    }
}

private extension SnapshotTests {
    static let directory = "__OUT__"

    static let card = CGSize(width: 361, height: 504)

    static let tall = CGSize(width: 361, height: 900)

    static var busy: TodayUsage {
        var hours = Array(repeating: TimeInterval(0), count: 24)
        hours[7] = 12 * 60
        hours[8] = 20 * 60
        hours[12] = 25 * 60
        hours[18] = 18 * 60
        hours[21] = 42 * 60
        hours[22] = 31 * 60

        var hourPickups = Array(repeating: 0, count: 24)
        hourPickups[7] = 6
        hourPickups[8] = 9
        hourPickups[12] = 11
        hourPickups[18] = 7
        hourPickups[21] = 13
        hourPickups[22] = 8

        return TodayUsage(
            total: hours.reduce(0, +),
            apps: [
                app("X", minutes: 48, pickups: 21, notifications: 63),
                app("YouTube", minutes: 35, pickups: 9, notifications: 4),
                app("Instagram", minutes: 22, pickups: 14, notifications: 18),
                app("LINE", minutes: 9, pickups: 8, notifications: 11),
                app("TikTok", minutes: 3, pickups: 2, notifications: 0)
            ],
            hours: hours,
            hourPickups: hourPickups,
            hourNotifications: hourPickups.map { $0 * 2 },
            pickups: 54,
            notifications: 96,
            firstPickup: Date(timeIntervalSince1970: 1_763_272_800),
            yesterdayTotal: 173 * 60,
            categories: [
                CategoryUsage(id: "SNS", name: "SNS", duration: 85 * 60),
                CategoryUsage(id: "ほか", name: "ほか", duration: 45 * 60),
                CategoryUsage(id: "エンタメ", name: "エンタメ", duration: 40 * 60),
                CategoryUsage(id: "ゲーム", name: "ゲーム", duration: 12 * 60),
                CategoryUsage(id: "仕事効率化", name: "仕事効率化", duration: 6 * 60),
                CategoryUsage(id: "教育", name: "教育", duration: 5 * 60)
            ]
        )
    }

    static var light: TodayUsage {
        var hours = Array(repeating: TimeInterval(0), count: 24)
        hours[9] = 4 * 60
        hours[13] = 6 * 60

        return TodayUsage(
            total: hours.reduce(0, +),
            apps: [
                app("LINE", minutes: 7, pickups: 6, notifications: 8)
            ],
            hours: hours,
            hourPickups: Array(repeating: 0, count: 24),
            hourNotifications: Array(repeating: 0, count: 24),
            pickups: 6,
            notifications: 8,
            firstPickup: nil,
            yesterdayTotal: 5 * 60,
            categories: [
                CategoryUsage(id: "SNS", name: "SNS", duration: 6 * 60),
                CategoryUsage(
                    id: "仕事効率化とファイナンス",
                    name: "仕事効率化とファイナンス",
                    duration: 4 * 60
                )
            ]
        )
    }

    static var empty: TodayUsage {
        TodayUsage(
            total: 0,
            apps: [],
            hours: Array(repeating: 0, count: 24),
            hourPickups: Array(repeating: 0, count: 24),
            hourNotifications: Array(repeating: 0, count: 24),
            pickups: 0,
            notifications: 0,
            firstPickup: nil,
            yesterdayTotal: nil,
            categories: []
        )
    }

    static func cases() -> [Case] {
        [
            Case(name: "usage-busy", size: tall) {
                AnyView(TodayUsageView(usage: busy))
            },
            Case(name: "usage-light", size: tall) {
                AnyView(TodayUsageView(usage: light))
            },
            Case(name: "usage-empty", size: tall) {
                AnyView(TodayUsageView(usage: empty))
            }
        ]
    }

    static func app(
        _ name: String,
        minutes: Double,
        pickups: Int,
        notifications: Int
    ) -> AppUsage {
        AppUsage(
            id: name,
            name: name,
            token: nil,
            duration: minutes * 60,
            pickups: pickups,
            notifications: notifications
        )
    }

    static func write(
        _ view: some View,
        to name: String
    ) throws {
        let renderer = ImageRenderer(content: view)

        renderer.scale = 2

        let data = try #require(renderer.uiImage?.pngData())
        let url = URL(fileURLWithPath: directory).appending(path: name)

        try data.write(to: url)
    }
}
