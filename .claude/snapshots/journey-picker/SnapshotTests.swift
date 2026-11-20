import Core
import DesignSystem
@testable import Features
import Store
import SwiftUI
import Testing
import UIKit

@MainActor
struct SnapshotTests {
    @Test
    func render() throws {
        for item in try Self.cases() {
            let view = item.view()
                .frame(width: item.size.width, height: item.size.height)
                .background(Palette.paper)
                .environment(\.colorScheme, .light)

            try Self.write(view, to: "\(item.name).png")
        }
    }
}

extension SnapshotTests {
    struct Case {
        let name: String
        let size: CGSize
        let view: () -> AnyView
    }
}

private extension SnapshotTests {
    static let directory = "__OUT__"

    static let sheet = CGSize(width: 393, height: 1100)

    static func cases() throws -> [Case] {
        let start = Date(timeIntervalSince1970: 1_000_000)
        let now = start.addingTimeInterval(300 * 60)
        let database = try AppDatabase.inMemory()

        _ = try database.startTrip(minutes: 270, at: start)

        let one = JourneyPickerModel(
            database: database,
            now: { now },
            isAvailable: { $0 == .tokyoToKyoto }
        )
        let all = JourneyPickerModel(
            database: database,
            now: { now },
            isAvailable: { _ in true }
        )

        all.selectedID = Journey.okinawa.id

        let finished = JourneyPickerModel(
            database: database,
            now: { now },
            isAvailable: { _ in true }
        )

        finished.filter = .all

        return [
            Case(name: "picker-one", size: sheet) {
                AnyView(JourneyPickerSheet(model: one) {})
            },
            Case(name: "picker-all", size: sheet) {
                AnyView(JourneyPickerSheet(model: all) {})
            },
            Case(name: "picker-finished", size: sheet) {
                AnyView(JourneyPickerSheet(model: finished) {})
            }
        ]
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
