import Core
import DesignSystem
import DeviceActivity
import FamilyControls
import Foundation
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

    public var look: RoomLook {
        didSet {
            look.save(to: defaults)
        }
    }

    public private(set) var companion: Companion?
    public private(set) var progress: JourneyProgress?
    public private(set) var finishedTrip: Trip?
    public private(set) var finishedArrivals: [Arrival] = []
    public private(set) var decoratedArrivals: [Arrival] = []
    public private(set) var arrivals: [Arrival] = []
    public private(set) var practiceArrivals: [Arrival] = []
    public private(set) var isAuthorized = false
    public private(set) var hasSelection = false

    public private(set) var journey = Journey.tokyoSightseeing

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let now: @MainActor () -> Date
    @ObservationIgnored private let center = DeviceActivityCenter()

    public init(
        database: AppDatabase,
        defaults: UserDefaults = .standard,
        now: @escaping @MainActor () -> Date = { .now }
    ) {
        let saved = defaults.integer(forKey: Self.selectedMinutesKey)

        self.database = database
        self.defaults = defaults
        self.now = now
        self.selectedMinutes = Self.isTripLength(saved) ? saved : 25
        self.look = RoomLook(defaults: defaults)

        refresh()
    }
}

public extension RoomModel {
    #if DEBUG
    static let tripPresets = [1, 25, 45, 60, 90, 120]
    static let tripRange = 1...180
    #else
    static let tripPresets = [15, 25, 45, 60, 90, 120]
    static let tripRange = 5...180
    #endif

    static let tripStep = 5

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

    var postcardLimit: Int {
        kilometersToNext == nil ? 3 : 2
    }

    var decorPostcards: [Landmark] {
        practiceArrivals.map(\.landmark) + journey.landmarks.dropFirst()
    }

    var tripJourney: Journey {
        progress?.activeTrip?.isPractice == true ? .practice : journey
    }

    var hungPostcards: [Landmark] {
        decoratedArrivals.suffix(postcardLimit).map(\.landmark)
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

    static func isTripLength(_ minutes: Int) -> Bool {
        tripRange.contains(minutes) && (minutes % tripStep == 0 || tripPresets.contains(minutes))
    }

    func lengthNote(for minutes: Int) -> String {
        let distance = minutes * Trip.kilometersPerMinute
        let reached = journey.landmarkReached(from: kilometers, to: kilometers + distance)

        guard let reached else {
            return "+\(distance.formatted()) km"
        }

        return "\(reached.name)に着く"
    }

    func kilometers(at date: Date) -> Int {
        let progress = try? database.journeyProgress(at: date)
        return progress?.kilometers ?? kilometers
    }

    func isArrived(_ landmark: Landmark) -> Bool {
        (arrivals + practiceArrivals).contains { $0.landmark == landmark }
    }

    func makeJourneyPicker() -> JourneyPickerModel {
        JourneyPickerModel(database: database, now: now)
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
        journey = (try? database.currentJourney()) ?? .tokyoSightseeing
        companion = try? database.companion()
        progress = try? database.journeyProgress(at: now())

        endLeftOverShield()
        saveShieldSnapshot()
        recordArrivals()
        updateFinishedTrip()
        updateFinishedArrivals()
        decoratedArrivals = (try? database.decoratedArrivals()) ?? []
        arrivals = (try? database.arrivals(journeyID: journey.id)) ?? []
        practiceArrivals = (try? database.arrivals(journeyID: Journey.practice.id)) ?? []
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

    func toggleHung(_ landmark: Landmark) {
        var chosen = hungPostcards

        if let index = chosen.firstIndex(of: landmark) {
            chosen.remove(at: index)
        } else {
            if chosen.count >= postcardLimit {
                chosen.removeFirst()
            }

            chosen.append(landmark)
        }

        hang(chosen)
    }

    func hang(_ chosen: [Landmark]) {
        let kept = decoratedArrivals.map(\.landmark).filter { chosen.contains($0) }
        let matching = zip(kept, chosen).prefix { $0 == $1 }.count
        let removed = decoratedArrivals.map(\.landmark).filter { !chosen.contains($0) }
        let staying = kept.prefix(matching)
        let latest = decoratedArrivals
            .filter { staying.contains($0.landmark) }
            .compactMap(\.decoratedAt)
            .max()
        let start = max(now(), latest.map { $0.addingTimeInterval(Self.hangStep) } ?? .distantPast)

        do {
            for landmark in removed + kept.dropFirst(matching) {
                try database.setDecorated(false, landmark: landmark, at: start)
            }

            for (offset, landmark) in chosen.dropFirst(matching).enumerated() {
                let time = start.addingTimeInterval(Double(offset) * Self.hangStep)
                try database.setDecorated(true, landmark: landmark, at: time)
            }
        } catch {
            EventLog.append("絵はがき：飾りを替えられない（\(error.localizedDescription)）")
        }

        updateFinishedArrivals()
        decoratedArrivals = (try? database.decoratedArrivals()) ?? []
    }

    func startTrip() {
        startTrip(minutes: selectedMinutes)
    }

    func startPracticeTrip() {
        begin(label: "練習") { start in
            try database.startPracticeTrip(at: start)
        }
    }

    func startTrip(minutes: Int) {
        begin(label: "\(minutes) 分") { start in
            try database.startTrip(minutes: minutes, at: start)
        }
    }

    func stopTrip() {
        if let trip = progress?.activeTrip {
            do {
                try database.endTrip(trip.id, at: now())
            } catch {
                EventLog.append("旅：終わりを保存できない（\(error.localizedDescription)）")
            }
        }

        FocusShield.endTrip()
        EventLog.append("旅：やめた")
        refresh()
    }
}

private extension RoomModel {
    static let selectedMinutesKey = "room.selectedMinutes"
    static let acknowledgedTripKey = "room.acknowledgedTripID"
    static let hangStep: TimeInterval = 0.01

    func endLeftOverShield() {
        let isLeftOver = FocusEnd.isLeftOver(
            endsAt: FocusShield.tripEndsAt,
            hasActiveTrip: progress?.activeTrip != nil,
            at: now()
        )

        guard isLeftOver else {
            return
        }

        FocusShield.endTrip()
        EventLog.append("旅：残っていた止める設定を外した")
    }

    func saveShieldSnapshot() {
        let snapshot = ShieldSnapshot(
            companion: companion,
            journey: journey,
            totalKilometers: progress?.kilometers ?? 0,
            activeTrip: progress?.activeTrip,
            at: now()
        )

        if let snapshot {
            snapshot.save()
        } else {
            ShieldSnapshot.clear()
        }
    }

    func begin(
        label: String,
        save: (Date) throws -> Trip
    ) {
        let start = now()
        let trip: Trip

        do {
            trip = try save(start)
        } catch {
            EventLog.append("旅：保存できない（\(error.localizedDescription)）")
            refresh()
            return
        }

        let schedule = FocusShield.schedule(from: start, to: trip.plannedEnd)
        let name = ScreenTimeShared.focusActivityName(tripID: trip.id.description)
        let oldWatches = center.activities.filter { ScreenTimeShared.isFocusActivity($0.rawValue) }

        center.stopMonitoring(oldWatches)
        FocusShield.startTrip(endsAt: trip.plannedEnd)

        do {
            try center.startMonitoring(DeviceActivityName(name), during: schedule)
            EventLog.append("旅：開始（\(label)）")
        } catch {
            FocusShield.endTrip()
            try? database.endTrip(trip.id, at: start)
            defaults.set(trip.id.description, forKey: Self.acknowledgedTripKey)
            EventLog.append("旅：見張りを始められない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func recordArrivals() {
        do {
            try database.recordArrivals(on: journey, at: now())
            try database.recordPracticeArrivals(at: now())
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
}
