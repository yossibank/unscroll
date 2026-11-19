import Core
import Foundation
import GRDB

public extension AppDatabase {
    func currentJourney() throws -> Journey {
        try writer.read { db in
            try Self.currentJourney(db)
        }
    }

    @discardableResult
    func selectJourney(
        _ id: String,
        at now: Date
    ) throws -> Bool {
        try writer.write { db in
            let trips = try Trip.fetchAll(db)

            guard
                Journey.with(id: id) != nil,
                !trips.contains(where: { $0.isActive(at: now) })
            else {
                return false
            }

            try db.execute(
                sql: "insert or replace into currentJourney (id, journeyID) values (1, ?)",
                arguments: [id]
            )

            return true
        }
    }
}

extension AppDatabase {
    static func currentJourney(_ db: Database) throws -> Journey {
        if try db.tableExists("currentJourney"),
           let id = try String.fetchOne(
               db,
               sql: "select journeyID from currentJourney where id = 1"
           ) {
            return Journey.with(id: id) ?? .tokyoToKyoto
        }

        return try latestTripJourney(db)
    }
}

private extension AppDatabase {
    static func latestTripJourney(_ db: Database) throws -> Journey {
        guard
            try db.tableExists("trip"),
            let row = try Row.fetchOne(
                db,
                sql: "select * from trip order by startedAt desc limit 1"
            )
        else {
            return .tokyoSightseeing
        }

        let id: String? = row["journeyID"]
        return id.flatMap { Journey.with(id: $0) } ?? .tokyoToKyoto
    }
}
