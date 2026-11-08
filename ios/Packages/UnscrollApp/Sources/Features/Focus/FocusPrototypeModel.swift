import Core
import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import Observation

@MainActor
@Observable
public final class FocusPrototypeModel {
    public var selection = FamilyActivitySelection()

    public private(set) var isAuthorized = false
    public private(set) var focusEndsAt: Date?
    public private(set) var logLines: [String] = []

    @ObservationIgnored private let center = DeviceActivityCenter()
    @ObservationIgnored private let defaults = UserDefaults(suiteName: ScreenTimeShared.appGroup)

    @ObservationIgnored private let store = ManagedSettingsStore(
        named: ManagedSettingsStore.Name(ScreenTimeShared.focusStoreName)
    )

    public init() {
        loadSelection()
        refresh()
    }
}

public extension FocusPrototypeModel {
    var selectionSummary: String {
        let apps = selection.applicationTokens.count
        let categories = selection.categoryTokens.count
        let domains = selection.webDomainTokens.count
        return "アプリ \(apps)・カテゴリ \(categories)・サイト \(domains)"
    }

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty
            || !selection.categoryTokens.isEmpty
            || !selection.webDomainTokens.isEmpty
    }

    func refresh() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        logLines = EventLog.lines()
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            EventLog.append("許可：取れた")
        } catch {
            EventLog.append("許可：取れない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func saveSelection() {
        let data = try? JSONEncoder().encode(selection)
        defaults?.set(data, forKey: ScreenTimeShared.selectionKey)
        EventLog.append("選択：\(selectionSummary)")
        refresh()
    }

    func startFocus(minutes: Int) {
        let start = Date.now
        let end = start.addingTimeInterval(TimeInterval(minutes * 60))
        let schedule = makeSchedule(from: start, to: end)

        shieldSelection()

        do {
            try center.startMonitoring(
                DeviceActivityName(ScreenTimeShared.focusActivityName),
                during: schedule
            )
            focusEndsAt = end
            EventLog.append("集中：開始（\(minutes) 分）")
        } catch {
            store.clearAllSettings()
            EventLog.append("集中：見張りを始められない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func stopFocus() {
        store.clearAllSettings()
        center.stopMonitoring([DeviceActivityName(ScreenTimeShared.focusActivityName)])
        focusEndsAt = nil
        EventLog.append("集中：やめた")
        refresh()
    }

    func startUsageWatch() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )

        do {
            try center.startMonitoring(
                DeviceActivityName(ScreenTimeShared.usageActivityName),
                during: schedule,
                events: makeUsageEvents()
            )
            EventLog.append("区切り：見張りを始めた（\(ScreenTimeShared.usageThresholdMinutes) 分）")
        } catch {
            EventLog.append("区切り：見張りを始められない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func clearLog() {
        EventLog.clear()
        refresh()
    }
}

private extension FocusPrototypeModel {
    func loadSelection() {
        guard
            let data = defaults?.data(forKey: ScreenTimeShared.selectionKey),
            let saved = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else {
            return
        }

        selection = saved
    }

    func shieldSelection() {
        let apps = selection.applicationTokens
        let categories = selection.categoryTokens
        let domains = selection.webDomainTokens

        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        store.shield.webDomains = domains.isEmpty ? nil : domains
    }

    func makeSchedule(
        from start: Date,
        to end: Date
    ) -> DeviceActivitySchedule {
        let components: Set<Calendar.Component> = [.hour, .minute, .second]
        let calendar = Calendar.current

        return DeviceActivitySchedule(
            intervalStart: calendar.dateComponents(components, from: start),
            intervalEnd: calendar.dateComponents(components, from: end),
            repeats: false
        )
    }

    func makeUsageEvents() -> [DeviceActivityEvent.Name: DeviceActivityEvent] {
        let pairs = ScreenTimeShared.usageThresholdMinutes.map { minutes in
            let name = DeviceActivityEvent.Name(ScreenTimeShared.usageEventName(minutes: minutes))

            let event = DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                webDomains: selection.webDomainTokens,
                threshold: DateComponents(minute: minutes)
            )

            return (name, event)
        }

        return Dictionary(uniqueKeysWithValues: pairs)
    }
}
