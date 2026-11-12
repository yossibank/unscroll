import Core
import DesignSystem
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

    static let row = CGSize(width: 393, height: 160)

    static func cases() throws -> [Case] {
        try Companion.Species.allCases.map { species in
            let companions = try species.coats.map { coat in
                try #require(Companion(species: species, coat: coat, name: species.defaultName))
            }

            return Case(name: "stickers-\(species.rawValue)", size: row) {
                AnyView(
                    HStack(spacing: 16) {
                        ForEach(companions, id: \.coat) { companion in
                            CompanionSticker(
                                companion: companion,
                                pose: .walk,
                                size: 80,
                                breathes: false
                            )
                        }
                    }
                )
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
