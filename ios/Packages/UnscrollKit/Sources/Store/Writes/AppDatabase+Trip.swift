import Core
import Foundation
import GRDB

public extension AppDatabase {
    func startTrip(minutes: Int, at now: Date) throws -> Trip {
        try writer.write { db in
            let journey = try Self.currentJourney(db)
            let trip = Trip(startedAt: now, plannedMinutes: minutes)

            try Self.insert(trip, journeyID: journey.id, at: now, db)

            return trip
        }
    }

    func startPracticeTrip(at now: Date) throws -> Trip {
        try writer.write { db in
            let trip = Trip(startedAt: now, plannedMinutes: 1, isPractice: true)

            try Self.insert(trip, journeyID: Journey.practice.id, at: now, db)

            return trip
        }
    }

    func endTrip(_ id: Trip.ID, at now: Date) throws {
        try writer.write { db in
            guard
                var trip = try Trip.fetchOne(db, key: id.description),
                trip.isActive(at: now)
            else {
                return
            }

            trip.endedAt = now
            try trip.update(db)
        }
    }
}

private extension AppDatabase {
    static func insert(
        _ trip: Trip,
        journeyID: String,
        at now: Date,
        _ db: Database
    ) throws {
        for var active in try Trip.fetchAll(db) where active.isActive(at: now) {
            active.endedAt = now
            try active.update(db)
        }

        try trip.insert(db)

        try db.execute(
            sql: "update trip set journeyID = ? where id = ?",
            arguments: [journeyID, trip.id.description]
        )
    }
}
