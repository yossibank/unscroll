import Core
import Foundation
import GRDB

public struct JourneyProgress: Hashable, Sendable {
    public let activeTrip: Trip?
    public let lastTrip: Trip?
    public let kilometers: Int

    public init(
        activeTrip: Trip?,
        lastTrip: Trip?,
        kilometers: Int
    ) {
        self.activeTrip = activeTrip
        self.lastTrip = lastTrip
        self.kilometers = kilometers
    }
}

public extension JourneyProgress {
    static func fetch(
        _ db: Database,
        journeyID: String,
        at now: Date
    ) throws -> JourneyProgress {
        let trips = try Trip.fetchAll(db)
        let ids = try String.fetchSet(
            db,
            sql: "select id from trip where journeyID = ?",
            arguments: [journeyID]
        )

        let kilometers = trips
            .filter { ids.contains($0.id.description) }
            .reduce(0) { $0 + $1.kilometers(at: now) }

        let activeTrip = trips
            .filter { $0.isActive(at: now) }
            .max { $0.startedAt < $1.startedAt }

        let lastTrip = trips.max { $0.startedAt < $1.startedAt }

        return JourneyProgress(
            activeTrip: activeTrip,
            lastTrip: lastTrip,
            kilometers: kilometers
        )
    }
}

public extension AppDatabase {
    func journeyProgress(at now: Date) throws -> JourneyProgress {
        try writer.read { db in
            let journey = try Self.currentJourney(db)
            return try JourneyProgress.fetch(db, journeyID: journey.id, at: now)
        }
    }
}
