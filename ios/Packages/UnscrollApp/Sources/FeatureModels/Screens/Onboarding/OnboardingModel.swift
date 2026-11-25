import Core
import Foundation
import Observation

@MainActor
@Observable
public final class OnboardingModel {
    public private(set) var page = Page.travel

    public let companion: CompanionPickerModel
    public let settings: SettingsModel

    @ObservationIgnored private let defaults: UserDefaults

    public init(
        parts: ScreenParts,
        settings: SettingsModel,
        defaults: UserDefaults = .standard
    ) {
        self.companion = CompanionPickerModel(parts: parts)
        self.settings = settings
        self.defaults = defaults
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
        case practice
    }

    static let introPages: [Page] = [.travel, .walk, .postcard, .usage]
    static let setupPages: [Page] = [.companion, .permission, .apps, .practice]
    static let completedKey = "onboardingCompleted"

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

    static func isCompleted(in defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: completedKey)
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

    func complete() {
        defaults.set(true, forKey: Self.completedKey)
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

    func requestAuthorization() async -> Bool {
        guard !settings.isRequestingAuthorization else {
            return false
        }

        await settings.requestAuthorization()

        return settings.isAuthorized && page == .permission
    }
}
