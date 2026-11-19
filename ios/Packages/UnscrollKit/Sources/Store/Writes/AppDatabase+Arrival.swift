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
                .filter(sql: "journeyID = ?", arguments: [journey.id])
                .order(Trip.Columns.startedAt)
                .fetchAll(db)

            var start = 0

            for trip in trips {
                if !trip.isActive(at: now) {
                    let arrivals = journey.arrivals(on: trip, startingAt: start, at: now)

                    for arrival in arrivals {
                        try arrival.insert(db, onConflict: .ignore)

                        try db.execute(
                            sql: "update arrival set journeyID = ? where landmarkName = ?",
                            arguments: [journey.id, arrival.landmark.name]
                        )
                    }
                }

                start += trip.kilometers(at: now)
            }
        }
    }

    func recordPracticeArrivals(at now: Date) throws {
        guard let station = Journey.practiceStation else {
            return
        }

        try writer.write { db in
            let trips = try Trip
                .filter(sql: "journeyID = ?", arguments: [Journey.practice.id])
                .fetchAll(db)

            for trip in trips where !trip.isActive(at: now) && trip.isCompleted {
                let arrival = Arrival(
                    landmark: station,
                    tripID: trip.id,
                    arrivedAt: trip.plannedEnd
                )

                try arrival.insert(db, onConflict: .ignore)

                try db.execute(
                    sql: "update arrival set journeyID = ? where landmarkName = ?",
                    arguments: [Journey.practice.id, station.name]
                )
            }
        }
    }
}
