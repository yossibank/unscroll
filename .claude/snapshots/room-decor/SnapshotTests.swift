import Core
import DesignSystem
@testable import FeatureModels
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

    static let room = CGSize(width: 361, height: 281)
    static let sheet = CGSize(width: 393, height: 480)

    static let looks: [RoomLook] = [
        RoomLook(wall: .plaster, floor: .wood),
        RoomLook(wall: .dots, floor: .tatami),
        RoomLook(wall: .stripe, floor: .tile),
        RoomLook(wall: .stars, floor: .wood)
    ]

    static func cases() throws -> [Case] {
        let companion = try #require(
            Companion(species: .shiba, coat: Companion.Species.shiba.coats[0], name: "こむぎ")
        )
        let database = try AppDatabase.inMemory()

        _ = try database.startTrip(minutes: 300, at: .now.addingTimeInterval(-310 * 60))

        let model = RoomModel(
            parts: ScreenParts(database: database, clock: .system),
            defaults: UserDefaults(suiteName: "snapshot") ?? .standard
        )
        let journey = Journey.tokyoToKyoto

        model.refresh()
        model.hang([journey.landmarks[3], journey.landmarks[1]])
        model.look = RoomLook()

        let rooms = looks.map { look in
            Case(name: "room-\(look.wall.rawValue)-\(look.floor.rawValue)", size: room) {
                AnyView(
                    RoomScene(
                        companion: companion,
                        look: look,
                        pose: .walk,
                        window: journey.landmarks[4],
                        postcards: model.hungPostcards,
                        nextRemaining: 90,
                        souvenirs: [],
                        onPoke: {}
                    )
                )
            }
        }
        let decor = Case(name: "sheet-wall", size: sheet) {
            AnyView(RoomDecorSheet(model: model) {})
        }

        return rooms + [decor]
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
