import Core
import Foundation
import GRDB

public struct JourneyProgress: Hashable, Sendable {
    public let activeTrip: Trip?
    public let kilometers: Int

    public init(
        activeTrip: Trip?,
        kilometers: Int
    ) {
        self.activeTrip = activeTrip
        self.kilometers = kilometers
    }
}

public extension JourneyProgress {
    static func fetch(_ db: Database, at now: Date) throws -> JourneyProgress {
        let trips = try Trip.fetchAll(db)
        let kilometers = trips.reduce(0) { $0 + $1.kilometers(at: now) }

        let activeTrip = trips
            .filter { $0.isActive(at: now) }
            .max { $0.startedAt < $1.startedAt }

        return JourneyProgress(
            activeTrip: activeTrip,
            kilometers: kilometers
        )
    }
}

public extension AppDatabase {
    func journeyProgress(at now: Date) throws -> JourneyProgress {
        try writer.read { db in
            try JourneyProgress.fetch(db, at: now)
        }
    }
}
