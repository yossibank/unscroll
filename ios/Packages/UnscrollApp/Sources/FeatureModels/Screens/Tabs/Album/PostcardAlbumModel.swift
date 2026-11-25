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

    @ObservationIgnored private let parts: ScreenParts

    public init(parts: ScreenParts) {
        self.parts = parts

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
            try parts.database.setDecorated(isDecorated, landmark: landmark, at: parts.clock.now)
        } catch {
            EventLog.append("絵はがき：飾れない（\(error.localizedDescription)）", at: parts.clock.now)
        }

        refresh()
    }

    func show(_ journeyID: String) {
        shownJourneyID = journeyID
        refresh()
    }

    func refresh() {
        let date = parts.clock.now
        let current = (try? parts.database.currentJourney()) ?? .tokyoSightseeing

        do {
            try parts.database.recordArrivals(on: current, at: date)
        } catch {
            EventLog.append("名所：着いた記録を保存できない（\(error.localizedDescription)）", at: parts.clock.now)
        }

        covers = Journey.all.map { journey in
            Cover(
                journey: journey,
                collectedCount: (try? parts.database.arrivals(journeyID: journey.id))?.count ?? 0,
                kilometers: journeyKilometers(journey, at: date),
                isCurrent: journey.id == current.id
            )
        }

        journey = shownJourneyID.flatMap(Journey.with(id:)) ?? current
        kilometers = journeyKilometers(journey, at: date)
        arrivals = (try? parts.database.arrivals(journeyID: journey.id)) ?? []
    }
}

private extension PostcardAlbumModel {
    func journeyKilometers(
        _ journey: Journey,
        at date: Date
    ) -> Int {
        let progress = try? parts.database.journeyProgress(journeyID: journey.id, at: date)
        return min(progress?.kilometers ?? 0, journey.totalKilometers)
    }
}
