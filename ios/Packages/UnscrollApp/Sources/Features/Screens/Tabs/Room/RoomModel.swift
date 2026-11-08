import Core
import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import Observation
import Store

@MainActor
@Observable
public final class RoomModel {
    public private(set) var progress: JourneyProgress?
    public private(set) var isAuthorized = false
    public private(set) var hasSelection = false

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let center = DeviceActivityCenter()

    @ObservationIgnored private let store = ManagedSettingsStore(
        named: ManagedSettingsStore.Name(ScreenTimeShared.focusStoreName)
    )

    public init(database: AppDatabase) {
        self.database = database
        refresh()
    }
}

public extension RoomModel {
    var tripEndsAt: Date? {
        progress?.activeTrip?.plannedEnd
    }

    var canStart: Bool {
        isAuthorized && hasSelection && progress?.activeTrip == nil
    }

    func refresh() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        hasSelection = !BlockedApps.isEmpty(BlockedApps.load())
        progress = try? database.journeyProgress(at: .now)
    }

    func startTrip(minutes: Int) {
        let start = Date.now
        let end = start.addingTimeInterval(TimeInterval(minutes * 60))
        let schedule = makeSchedule(from: start, to: end)

        let trip: Trip

        do {
            trip = try database.startTrip(minutes: minutes, at: start)
        } catch {
            EventLog.append("旅：保存できない（\(error.localizedDescription)）")
            refresh()
            return
        }

        shieldSelection(BlockedApps.load())

        do {
            try center.startMonitoring(
                DeviceActivityName(ScreenTimeShared.focusActivityName),
                during: schedule
            )
            EventLog.append("旅：開始（\(minutes) 分）")
        } catch {
            store.clearAllSettings()
            try? database.endTrip(trip.id, at: start)
            EventLog.append("旅：見張りを始められない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func stopTrip() {
        if let trip = progress?.activeTrip {
            do {
                try database.endTrip(trip.id, at: .now)
            } catch {
                EventLog.append("旅：終わりを保存できない（\(error.localizedDescription)）")
            }
        }

        store.clearAllSettings()
        center.stopMonitoring([DeviceActivityName(ScreenTimeShared.focusActivityName)])
        EventLog.append("旅：やめた")
        refresh()
    }
}

private extension RoomModel {
    func shieldSelection(_ selection: FamilyActivitySelection) {
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
}
