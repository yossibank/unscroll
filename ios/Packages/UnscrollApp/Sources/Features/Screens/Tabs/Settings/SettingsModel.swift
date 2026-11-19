import Core
import DeviceActivity
import FamilyControls
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class SettingsModel {
    public var selection: FamilyActivitySelection

    public var strictness: Strictness {
        didSet {
            FocusShield.strictness = strictness
        }
    }

    public private(set) var companion: Companion?
    public private(set) var activeSetID: UUID?
    public private(set) var isAuthorized = false
    public private(set) var isTripActive = false
    public private(set) var kilometersTogether = 0
    public private(set) var logLines: [String] = []

    private(set) var sets: [BlockedAppSet]

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let center = DeviceActivityCenter()

    public init(database: AppDatabase) {
        let sets = BlockedApps.loadSets()

        self.database = database
        self.selection = BlockedApps.load()
        self.strictness = FocusShield.strictness
        self.sets = sets
        self.activeSetID = BlockedApps.loadActiveSetID(in: sets)
        refresh()
    }
}

public extension SettingsModel {
    var hasSelection: Bool {
        !BlockedApps.isEmpty(selection)
    }

    var isReady: Bool {
        isAuthorized && hasSelection
    }

    var selectionSummary: String {
        hasSelection ? BlockedApps.summary(selection) : "未選択"
    }

    var activeSetName: String {
        activeSetIndex.map { sets[$0].name } ?? "止めるアプリ"
    }

    var canAddSet: Bool {
        sets.count < BlockedApps.maxSetCount && !isTripActive
    }

    func makeCompanionPicker() -> CompanionPickerModel {
        CompanionPickerModel(database: database)
    }

    func refresh() {
        companion = try? database.companion()
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        isTripActive = (try? database.journeyProgress(at: .now))?.activeTrip != nil
        kilometersTogether = totalKilometers(at: .now)
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
        if let index = activeSetIndex {
            sets[index].selection = selection
        }

        BlockedApps.save(selection)
        BlockedApps.saveSets(sets, activeID: activeSetID)
        refresh()
    }

    func selectSet(_ id: UUID) {
        guard
            !isTripActive,
            let set = sets.first(where: { $0.id == id })
        else {
            return
        }

        activeSetID = id
        selection = set.selection
        saveSelection()
    }

    func addSet(named name: String) {
        guard canAddSet else {
            return
        }

        let set = BlockedAppSet(
            id: UUID(),
            name: trimmedName(name, fallback: "セット \(sets.count + 1)"),
            selection: FamilyActivitySelection()
        )

        sets.append(set)
        selectSet(set.id)
    }

    func renameSet(
        _ id: UUID,
        to name: String
    ) {
        guard let index = sets.firstIndex(where: { $0.id == id }) else {
            return
        }

        sets[index].name = trimmedName(name, fallback: sets[index].name)
        BlockedApps.saveSets(sets, activeID: activeSetID)
    }

    func deleteSet(_ id: UUID) {
        guard
            sets.count > 1,
            !isTripActive
        else {
            return
        }

        sets.removeAll { $0.id == id }

        if activeSetID == id, let first = sets.first {
            selectSet(first.id)
        } else {
            BlockedApps.saveSets(sets, activeID: activeSetID)
        }
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

private extension SettingsModel {
    var activeSetIndex: Int? {
        sets.firstIndex { $0.id == activeSetID }
    }

    func trimmedName(
        _ name: String,
        fallback: String
    ) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(8))
    }

    func totalKilometers(at now: Date) -> Int {
        Journey.all.reduce(0) { total, journey in
            let progress = try? database.journeyProgress(journeyID: journey.id, at: now)
            return total + (progress?.kilometers ?? 0)
        }
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
