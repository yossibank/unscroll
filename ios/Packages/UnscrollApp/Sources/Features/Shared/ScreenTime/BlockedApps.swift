import Core
import FamilyControls
import Foundation

struct BlockedAppSet: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var selection: FamilyActivitySelection
}

@MainActor
enum BlockedApps {
    static let maxSetCount = 5
    static let setsKey = "screenTime.sets"
    static let activeSetKey = "screenTime.activeSet"

    private static let defaultSetName = "いつもの"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: ScreenTimeShared.appGroup)
    }

    static func load() -> FamilyActivitySelection {
        FocusShield.savedSelection()
    }

    static func save(_ selection: FamilyActivitySelection) {
        let data = try? JSONEncoder().encode(selection)
        defaults?.set(data, forKey: ScreenTimeShared.selectionKey)
        EventLog.append("選択：\(summary(selection))")
    }

    static func loadSets() -> [BlockedAppSet] {
        if let data = defaults?.data(forKey: setsKey),
           let sets = try? JSONDecoder().decode([BlockedAppSet].self, from: data),
           !sets.isEmpty {
            return sets
        }

        return [BlockedAppSet(id: UUID(), name: defaultSetName, selection: load())]
    }

    static func loadActiveSetID(in sets: [BlockedAppSet]) -> UUID? {
        let saved = defaults?.string(forKey: activeSetKey).flatMap(UUID.init(uuidString:))
        let ids = sets.map(\.id)
        return saved.flatMap { ids.contains($0) ? $0 : nil } ?? ids.first
    }

    static func saveSets(
        _ sets: [BlockedAppSet],
        activeID: UUID?
    ) {
        let data = try? JSONEncoder().encode(sets)
        defaults?.set(data, forKey: setsKey)
        defaults?.set(activeID?.uuidString, forKey: activeSetKey)
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
