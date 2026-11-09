import Core
import Foundation
import GRDB

public extension AppDatabase {
    func recordArrivals(
        on journey: Journey,
        at now: Date
    ) throws {
        try writer.write { db in
            let trips = try Trip
                .order(Trip.Columns.startedAt)
                .fetchAll(db)

            var start = 0

            for trip in trips {
                if !trip.isActive(at: now) {
                    let arrivals = journey.arrivals(on: trip, startingAt: start, at: now)

                    for arrival in arrivals {
                        try arrival.insert(db, onConflict: .ignore)
                    }
                }

                start += trip.kilometers(at: now)
            }
        }
    }
}
