import Core
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class PostcardAlbumModel {
    public private(set) var arrivals: [Arrival] = []
    public private(set) var covers: [Cover] = []
    public private(set) var kilometers = 0
    public private(set) var journey = Journey.tokyoSightseeing
    public private(set) var shownJourneyID: String?

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let now: @MainActor () -> Date

    public init(
        database: AppDatabase,
        now: @escaping @MainActor () -> Date = { .now }
    ) {
        self.database = database
        self.now = now

        refresh()
    }
}

public extension PostcardAlbumModel {
    struct Entry: Hashable, Sendable {
        public let landmark: Landmark
        public let arrival: Arrival?
        public let remainingKilometers: Int

        public var isCollected: Bool {
            arrival != nil
        }
    }

    struct Cover: Hashable, Identifiable, Sendable {
        public let journey: Journey
        public let collectedCount: Int
        public let kilometers: Int
        public let isCurrent: Bool

        public var id: String {
            journey.id
        }

        public var totalCount: Int {
            journey.landmarks.count - 1
        }

        public var isStarted: Bool {
            kilometers > 0 || collectedCount > 0
        }

        public var art: Landmark? {
            journey.landmarks.dropFirst().first
        }
    }

    var entries: [Entry] {
        journey.landmarks.dropFirst().map { landmark in
            Entry(
                landmark: landmark,
                arrival: arrival(at: landmark),
                remainingKilometers: max(0, landmark.kilometer - kilometers)
            )
        }
    }

    var collectedCount: Int {
        entries.count(where: \.isCollected)
    }

    var totalCount: Int {
        entries.count
    }

    func arrival(at landmark: Landmark) -> Arrival? {
        arrivals.first { $0.landmark.name == landmark.name }
    }

    func setDecorated(
        _ isDecorated: Bool,
        landmark: Landmark
    ) {
        do {
            try database.setDecorated(isDecorated, landmark: landmark, at: now())
        } catch {
            EventLog.append("絵はがき：飾れない（\(error.localizedDescription)）", at: now())
        }

        refresh()
    }

    func show(_ journeyID: String) {
        shownJourneyID = journeyID
        refresh()
    }

    func refresh() {
        let date = now()
        let current = (try? database.currentJourney()) ?? .tokyoSightseeing

        do {
            try database.recordArrivals(on: current, at: date)
        } catch {
            EventLog.append("名所：着いた記録を保存できない（\(error.localizedDescription)）", at: now())
        }

        covers = Journey.all.map { journey in
            Cover(
                journey: journey,
                collectedCount: (try? database.arrivals(journeyID: journey.id))?.count ?? 0,
                kilometers: journeyKilometers(journey, at: date),
                isCurrent: journey.id == current.id
            )
        }

        journey = shownJourneyID.flatMap(Journey.with(id:)) ?? current
        kilometers = journeyKilometers(journey, at: date)
        arrivals = (try? database.arrivals(journeyID: journey.id)) ?? []
    }
}

private extension PostcardAlbumModel {
    func journeyKilometers(
        _ journey: Journey,
        at date: Date
    ) -> Int {
        let progress = try? database.journeyProgress(journeyID: journey.id, at: date)
        return min(progress?.kilometers ?? 0, journey.totalKilometers)
    }
}
