import Core
import CoreText
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
        minutes: Int,
        isOnTrip: Bool
    ) throws -> JourneyMapModel {
        let database = try AppDatabase.inMemory()
        let companion = try #require(
            Companion(species: .shiba, coat: Companion.Species.shiba.coats[0], name: "こむぎ")
        )
        let now = Date(timeIntervalSince1970: 1_791_000_000)
        let start = now.addingTimeInterval(-Double(minutes) * 60)

        try database.saveCompanion(companion)
        _ = try database.selectJourney(Journey.worldHeritage.id, at: start.addingTimeInterval(-60))

        if minutes > 0 {
            let length = isOnTrip ? minutes * 2 : minutes
            _ = try database.startTrip(minutes: length, at: start)
        }

        return JourneyMapModel(parts: ScreenParts(database: database, clock: .fixed(now)))
    }

    static func page(_ model: JourneyMapModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            JournalTitle("旅の地図", note: "いま歩いている道のり")

            JourneyMapTicket(model: model) {}

            JourneyMapPaper(model: model)
                .padding(.vertical, Spacing.small)

            JourneyMapTag(
                journey: model.journey,
                nextLandmark: model.nextLandmark,
                kilometersToNext: model.kilometersToNext
            )
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, 60)
    }

    static func cases() throws -> [Case] {
        let states: [(String, Int, Bool)] = [
            ("start", 0, false),
            ("middle", 276, false),
            ("trip", 276, true),
            ("finished", 1250, false)
        ]

        return try states.map { name, minutes, isOnTrip in
            let model = try model(minutes: minutes, isOnTrip: isOnTrip)

            return Case(name: "map-tab-\(name)", size: page) {
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
