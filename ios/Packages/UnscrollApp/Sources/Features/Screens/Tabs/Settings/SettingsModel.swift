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

    public private(set) var isAuthorized = false
    public private(set) var isTripActive = false
    public private(set) var logLines: [String] = []

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let center = DeviceActivityCenter()

    public init(database: AppDatabase) {
        self.database = database
        self.selection = BlockedApps.load()
        refresh()
    }
}

public extension SettingsModel {
    var selectionSummary: String {
        BlockedApps.summary(selection)
    }

    func refresh() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        isTripActive = (try? database.journeyProgress(at: .now))?.activeTrip != nil
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
        BlockedApps.save(selection)
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

private extension SettingsModel {
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
