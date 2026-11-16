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
        guard try db.tableExists("currentJourney") else {
            return .tokyoToKyoto
        }

        let id = try String.fetchOne(db, sql: "select journeyID from currentJourney where id = 1")
        return id.flatMap { Journey.with(id: $0) } ?? .tokyoToKyoto
    }
}
