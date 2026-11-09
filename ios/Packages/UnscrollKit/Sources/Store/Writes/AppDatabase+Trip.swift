import Core
import Foundation
import GRDB

public extension AppDatabase {
    func startTrip(minutes: Int, at now: Date) throws -> Trip {
        try writer.write { db in
            let trips = try Trip.fetchAll(db)

            for var trip in trips where trip.isActive(at: now) {
                trip.endedAt = now
                try trip.update(db)
            }

            let trip = Trip(startedAt: now, plannedMinutes: minutes)
            try trip.insert(db)

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
