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

        let trip = try Self.model(name: "trip", elapsed: 40, length: 90)
        let result = try Self.model(name: "result", elapsed: 300, length: 240)
        let finished = try #require(result.finishedTrip)

        try Self.write(TripView(model: trip), to: "trip-active.png")

        try Self.write(
            TripResultSheet(trip: finished, model: result) {}
                .fixedSize(horizontal: false, vertical: true),
            to: "trip-result.png"
        )
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
        elapsed: Int,
        length: Int
    ) throws -> RoomModel {
        let database = try AppDatabase.inMemory()
        let suite = "trip-\(name)"
        let defaults = UserDefaults(suiteName: suite) ?? .standard
        let companion = try #require(
            Companion(species: .penguin, coat: Companion.Species.penguin.coats[0], name: "ぺんた")
        )
        let now = Date.now
        let start = now.addingTimeInterval(-Double(elapsed) * 60)

        defaults.removePersistentDomain(forName: suite)
        defaults.set("", forKey: "room.acknowledgedTripID")

        try database.saveCompanion(companion)
        _ = try database.selectJourney(Journey.worldHeritage.id, at: start.addingTimeInterval(-60))
        _ = try database.startTrip(minutes: length, at: start)

        return RoomModel(database: database, defaults: defaults, now: { now })
    }

    static func write(
        _ view: some View,
        to name: String
    ) throws {
        let root = view
            .frame(width: page.width, height: page.height, alignment: .top)
            .fontDesign(.rounded)
            .environment(\.colorScheme, .light)
        let renderer = ImageRenderer(content: root)

        renderer.scale = 2

        let data = try #require(renderer.uiImage?.pngData())
        let url = URL(fileURLWithPath: directory).appending(path: name)

        try data.write(to: url)
    }
}
