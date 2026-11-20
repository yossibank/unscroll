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

    static let page = CGSize(width: 393, height: 1180)

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

    static func page(
        companion: Companion?,
        strictness: Strictness,
        isTripActive: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium + 4) {
            JournalTitle("旅の支度", note: "出かける前に、ととのえる")

            SettingsPassport(companion: companion, kilometers: 276)

            SettingsPage("旅で止めるもの", tint: Palette.coral) {
                SettingsRow(
                    title: "止めるアプリ",
                    detail: "アプリ 3・カテゴリ 2・サイト 0",
                    systemImage: "hand.raised.fill",
                    tint: Palette.coral
                ) {
                    Image(systemName: "chevron.right")
                }

                SettingsRule()

                SettingsRow(title: "Screen Time の許可", systemImage: "hourglass", tint: Palette.sky) {
                    Label("許可あり", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Palette.teal)
                }
            }

            SettingsPage("外しにくさ", tint: Palette.sun) {
                SettingsStrictness(strictness: .constant(strictness), companion: companion)
                    .padding(.top, 4)
                    .opacity(isTripActive ? 0.5 : 1)

                if isTripActive {
                    Text("旅が終わったら変えられます")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.muted)
                        .padding(.horizontal, Spacing.small)
                        .padding(.top, 4)
                }
            }

            SettingsPage("このアプリについて", tint: Palette.teal) {
                SettingsRow(title: "お問い合わせ", systemImage: "envelope.fill", tint: Palette.teal) {
                    Image(systemName: "arrow.up.right")
                }

                SettingsRule()

                SettingsRow(title: "レビューを書く", systemImage: "star.fill", tint: Palette.sun) {
                    Image(systemName: "arrow.up.right")
                }
            }

            Text("おるすマホ 1.0.0")
                .font(.caption2.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(Palette.muted)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, 60)
    }

    static func cases() throws -> [Case] {
        let companion = try #require(
            Companion(species: .shiba, coat: Companion.Species.shiba.coats[0], name: "こむぎ")
        )

        return [
            Case(name: "settings-tab-normal", size: page) {
                AnyView(page(companion: companion, strictness: .normal, isTripActive: false))
            },
            Case(name: "settings-tab-trip", size: page) {
                AnyView(page(companion: companion, strictness: .strict, isTripActive: true))
            },
            Case(name: "settings-tab-no-companion", size: page) {
                AnyView(page(companion: nil, strictness: .gentle, isTripActive: false))
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
