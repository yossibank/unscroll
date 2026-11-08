import Core
import FamilyControls
import Foundation

@MainActor
enum BlockedApps {
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: ScreenTimeShared.appGroup)
    }

    static func load() -> FamilyActivitySelection {
        guard
            let data = defaults?.data(forKey: ScreenTimeShared.selectionKey),
            let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return FamilyActivitySelection()
        }

        return saved
    }

    static func save(_ selection: FamilyActivitySelection) {
        let data = try? JSONEncoder().encode(selection)
        defaults?.set(data, forKey: ScreenTimeShared.selectionKey)
        EventLog.append("選択：\(summary(selection))")
    }

    static func summary(_ selection: FamilyActivitySelection) -> String {
        let apps = selection.applicationTokens.count
        let categories = selection.categoryTokens.count
        let domains = selection.webDomainTokens.count
        return "アプリ \(apps)・カテゴリ \(categories)・サイト \(domains)"
    }

    static func isEmpty(_ selection: FamilyActivitySelection) -> Bool {
        selection.applicationTokens.isEmpty
            && selection.categoryTokens.isEmpty
            && selection.webDomainTokens.isEmpty
    }
}
