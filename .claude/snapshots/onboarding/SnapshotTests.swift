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

    static let page = CGSize(width: 375, height: 728)

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

    static func cases() throws -> [Case] {
        try OnboardingModel.Page.allCases.map { target in
            let database = try AppDatabase.inMemory()
            let settings = SettingsModel(database: database)
            let model = OnboardingModel(database: database, settings: settings)

            while model.page != target {
                if model.page == .companion {
                    model.saveCompanion()
                } else {
                    model.next()
                }
            }

            return Case(name: "onboarding-\(target.rawValue)", size: page) {
                AnyView(
                    OnboardingView(model: model) { _ in }
                        .padding(.top, 54)
                        .padding(.bottom, 24)
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
