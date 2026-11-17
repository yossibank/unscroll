import Core
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class OnboardingModel {
    public private(set) var page = Page.travel

    public let companion: CompanionPickerModel
    public let settings: SettingsModel

    public init(
        database: AppDatabase,
        settings: SettingsModel
    ) {
        self.companion = CompanionPickerModel(database: database)
        self.settings = settings
    }
}

public extension OnboardingModel {
    enum Page: Int, CaseIterable, Sendable {
        case travel
        case walk
        case postcard
        case usage
        case companion
        case permission
        case apps
    }

    static let introPages: [Page] = [.travel, .walk, .postcard, .usage]
    static let setupPages: [Page] = [.companion, .permission, .apps]

    var isIntro: Bool {
        Self.introPages.contains(page)
    }

    var setupStep: Int? {
        Self.setupPages.firstIndex(of: page).map { $0 + 1 }
    }

    var canGoBack: Bool {
        page != .travel
    }

    var canSkipIntro: Bool {
        isIntro && page != .usage
    }

    var canSwipeForward: Bool {
        isIntro
    }

    func next() {
        guard let next = Page(rawValue: page.rawValue + 1) else {
            return
        }

        page = next
    }

    func back() {
        guard let previous = Page(rawValue: page.rawValue - 1) else {
            return
        }

        page = previous
    }

    func skipIntro() {
        page = .companion
    }

    func saveCompanion() {
        guard companion.save() else {
            return
        }

        settings.refresh()
        next()
    }

    func requestAuthorization() async {
        await settings.requestAuthorization()

        if settings.isAuthorized {
            next()
        }
    }
}
