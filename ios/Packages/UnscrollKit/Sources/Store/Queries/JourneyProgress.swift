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
        let journeyTrips = try tripsOnJourney(journeyID, in: trips, db)
        let kilometers = journeyTrips.reduce(0) { $0 + $1.kilometers(at: now) }

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

private extension JourneyProgress {
    static func tripsOnJourney(
        _ journeyID: String,
        in trips: [Trip],
        _ db: Database
    ) throws -> [Trip] {
        let hasJourney = try db.columns(in: "trip").contains { $0.name == "journeyID" }

        guard hasJourney else {
            return trips
        }

        let ids = try String.fetchSet(
            db,
            sql: "select id from trip where journeyID = ?",
            arguments: [journeyID]
        )

        return trips.filter { ids.contains($0.id.description) }
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

public extension AppDatabase {
    func journeyProgress(
        journeyID: String,
        at now: Date
    ) throws -> JourneyProgress {
        try writer.read { db in
            try JourneyProgress.fetch(db, journeyID: journeyID, at: now)
        }
    }
}
