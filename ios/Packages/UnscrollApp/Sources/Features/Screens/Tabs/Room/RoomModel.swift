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
    public var selectedMinutes: Int {
        didSet {
            defaults.set(selectedMinutes, forKey: Self.selectedMinutesKey)
        }
    }

    public private(set) var companion: Companion?
    public private(set) var progress: JourneyProgress?
    public private(set) var finishedTrip: Trip?
    public private(set) var finishedArrivals: [Arrival] = []
    public private(set) var decoratedArrivals: [Arrival] = []
    public private(set) var isAuthorized = false
    public private(set) var hasSelection = false

    public let journey = Journey.tokyoToKyoto

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let now: @MainActor () -> Date
    @ObservationIgnored private let center = DeviceActivityCenter()

    @ObservationIgnored private let store = ManagedSettingsStore(
        named: ManagedSettingsStore.Name(ScreenTimeShared.focusStoreName)
    )

    public init(
        database: AppDatabase,
        defaults: UserDefaults = .standard,
        now: @escaping @MainActor () -> Date = { .now }
    ) {
        let saved = defaults.integer(forKey: Self.selectedMinutesKey)

        self.database = database
        self.defaults = defaults
        self.now = now
        self.selectedMinutes = Self.tripLengths.contains(saved) ? saved : 25

        refresh()
    }
}

public extension RoomModel {
    #if DEBUG
    static let tripLengths = [1, 25, 50, 90]
    #else
    static let tripLengths = [25, 50, 90]
    #endif

    var tripEndsAt: Date? {
        progress?.activeTrip?.plannedEnd
    }

    var kilometers: Int {
        progress?.kilometers ?? 0
    }

    var nextLandmark: Landmark? {
        journey.nextLandmark(after: kilometers)
    }

    var kilometersToNext: Int? {
        nextLandmark.map { $0.kilometer - kilometers }
    }

    var startTitle: String {
        guard let companion else {
            return "\(selectedMinutes) 分 旅に出す"
        }

        return "\(companion.name)と \(selectedMinutes) 分 旅に出る"
    }

    var canStart: Bool {
        isAuthorized && hasSelection && progress?.activeTrip == nil
    }

    func lengthNote(for minutes: Int) -> String {
        let distance = minutes * Trip.kilometersPerMinute
        let reached = journey.landmarkReached(from: kilometers, to: kilometers + distance)

        guard let reached else {
            return "+\(distance) km"
        }

        return "\(reached.name)に着く"
    }

    func kilometers(at date: Date) -> Int {
        let progress = try? database.journeyProgress(at: date)
        return progress?.kilometers ?? kilometers
    }

    func acknowledgeFinishedTrip() {
        guard let finishedTrip else {
            return
        }

        defaults.set(finishedTrip.id.description, forKey: Self.acknowledgedTripKey)
        self.finishedTrip = nil
    }

    func refresh() {
        isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
        hasSelection = !BlockedApps.isEmpty(BlockedApps.load())
        companion = try? database.companion()
        progress = try? database.journeyProgress(at: now())

        recordArrivals()
        updateFinishedTrip()
        updateFinishedArrivals()
        decoratedArrivals = (try? database.decoratedArrivals()) ?? []
    }

    func setDecorated(
        _ isDecorated: Bool,
        landmark: Landmark
    ) {
        do {
            try database.setDecorated(isDecorated, landmark: landmark, at: now())
        } catch {
            EventLog.append("絵はがき：飾れない（\(error.localizedDescription)）")
        }

        updateFinishedArrivals()
        decoratedArrivals = (try? database.decoratedArrivals()) ?? []
    }

    func startTrip() {
        let minutes = selectedMinutes
        let start = now()
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
            defaults.set(trip.id.description, forKey: Self.acknowledgedTripKey)
            EventLog.append("旅：見張りを始められない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func stopTrip() {
        if let trip = progress?.activeTrip {
            do {
                try database.endTrip(trip.id, at: now())
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
    static let selectedMinutesKey = "room.selectedMinutes"
    static let acknowledgedTripKey = "room.acknowledgedTripID"
    static let shortestScheduleSeconds: TimeInterval = 15 * 60

    func recordArrivals() {
        do {
            try database.recordArrivals(on: journey, at: now())
        } catch {
            EventLog.append("名所：着いた記録を保存できない（\(error.localizedDescription)）")
        }
    }

    func updateFinishedArrivals() {
        guard let finishedTrip else {
            finishedArrivals = []
            return
        }

        finishedArrivals = (try? database.arrivals(forTrip: finishedTrip.id)) ?? []
    }

    func updateFinishedTrip() {
        guard
            let progress,
            progress.activeTrip == nil
        else {
            return
        }

        let lastID = progress.lastTrip?.id.description ?? ""

        guard let acknowledged = defaults.string(forKey: Self.acknowledgedTripKey) else {
            defaults.set(lastID, forKey: Self.acknowledgedTripKey)
            return
        }

        if let lastTrip = progress.lastTrip, lastID != acknowledged {
            finishedTrip = lastTrip
        }
    }

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
        let minimum = start.addingTimeInterval(Self.shortestScheduleSeconds)
        let intervalEnd = max(end, minimum)
        let early = Int(intervalEnd.timeIntervalSince(end))

        return DeviceActivitySchedule(
            intervalStart: calendar.dateComponents(components, from: start),
            intervalEnd: calendar.dateComponents(components, from: intervalEnd),
            repeats: false,
            warningTime: early > 0 ? DateComponents(second: early) : nil
        )
    }
}
