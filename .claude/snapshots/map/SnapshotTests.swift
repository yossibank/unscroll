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

    static let map = CGSize(width: 361, height: 237)

    static let kilometers = [0, 10, 90, 100, 170, 260, 350, 360, 450, 500]

    static func cases() throws -> [Case] {
        let companion = try #require(
            Companion(species: .shiba, coat: Companion.Species.shiba.coats[0], name: "こむぎ")
        )

        let geometry = try #require(JourneyMapGeometry.for(Journey.tokyoToKyoto.id))

        return kilometers.map { kilometer in
            Case(name: "map-\(kilometer)", size: map) {
                AnyView(
                    JourneyMapCanvas(
                        journey: .tokyoToKyoto,
                        geometry: geometry,
                        kilometers: kilometer,
                        companion: companion
                    )
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
