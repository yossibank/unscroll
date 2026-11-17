import Core
import CoreText
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
        Self.registerFonts()

        for item in try Self.cases() {
            let view = item.view()
                .frame(width: item.size.width, height: item.size.height, alignment: .top)
                .background(PaperBackdrop())
                .fontDesign(.rounded)
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

    static let page = CGSize(width: 393, height: 852)

    static func registerFonts() {
        let fonts = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appending(path: "../../../../Unscroll/Fonts")
            .standardizedFileURL

        for name in ["ZenMaruGothic-Bold", "KleeOne-SemiBold"] {
            let url = fonts.appending(path: "\(name).ttf")
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func model(
        name: String,
        minutes: Int,
        isOnTrip: Bool
    ) throws -> RoomModel {
        let database = try AppDatabase.inMemory()
        let defaults = UserDefaults(suiteName: "room-tab-\(name)") ?? .standard
        let companion = try #require(
            Companion(species: .shiba, coat: Companion.Species.shiba.coats[0], name: "こむぎ")
        )
        let now = Date.now
        let start = now.addingTimeInterval(-Double(minutes) * 60)

        defaults.removePersistentDomain(forName: "room-tab-\(name)")

        try database.saveCompanion(companion)
        _ = try database.selectJourney(Journey.worldHeritage.id, at: start.addingTimeInterval(-60))

        if minutes > 0 {
            let length = isOnTrip ? minutes * 2 : minutes
            _ = try database.startTrip(minutes: length, at: start)
        }

        return RoomModel(database: database, defaults: defaults, now: { now })
    }

    static func page(_ model: RoomModel) -> some View {
        VStack(spacing: Spacing.medium) {
            RoomPhoto(model: model, pose: .walk) {}

            RoomTicket(model: model)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, 100)
    }

    static func cases() throws -> [Case] {
        let states: [(String, Int, Bool)] = [
            ("start", 0, false),
            ("middle", 276, false),
            ("trip", 276, true),
            ("finished", 1250, false)
        ]

        return try states.map { name, minutes, isOnTrip in
            let model = try model(name: name, minutes: minutes, isOnTrip: isOnTrip)

            return Case(name: "room-tab-\(name)", size: page) {
                AnyView(page(model))
            }
        }
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
