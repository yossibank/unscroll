import Core
import CoreText
import DesignSystem
@testable import Features
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

    static func entries(collected: Int) -> [PostcardAlbumModel.Entry] {
        let landmarks = Journey.worldHeritage.landmarks.dropFirst()
        let kilometers = landmarks.dropFirst(collected).first?.kilometer ?? 0

        return landmarks.enumerated().map { index, landmark in
            let arrival = index < collected
                ? Arrival(
                    landmark: landmark,
                    tripID: Trip.ID(),
                    arrivedAt: Date(timeIntervalSince1970: 1_793_000_000 + Double(index) * 600_000),
                    decoratedAt: index == 1 ? .now : nil
                )
                : nil

            return PostcardAlbumModel.Entry(
                landmark: landmark,
                arrival: arrival,
                remainingKilometers: max(0, landmark.kilometer - kilometers + 120)
            )
        }
    }

    static func album(_ entries: [PostcardAlbumModel.Entry]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            JournalTitle("絵はがき帳", note: Journey.worldHeritage.name)

            PostcardStampRally(
                entries: entries,
                collectedCount: entries.count(where: \.isCollected)
            )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.medium),
                    GridItem(.flexible(), spacing: Spacing.medium)
                ],
                spacing: Spacing.large
            ) {
                ForEach(Array(entries.enumerated()), id: \.element.landmark.name) { index, entry in
                    PostcardAlbumCard(entry: entry, index: index)
                }
            }
            .padding(.top, Spacing.small)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, 60)
    }

    static func cases() throws -> [Case] {
        [0, 3, 6].map { collected in
            Case(name: "album-\(collected)", size: page) {
                AnyView(album(entries(collected: collected)))
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
