import Core
import GRDB

extension Arrival {
    static func fetchAll(
        _ db: Database,
        forTrip id: Trip.ID
    ) throws -> [Arrival] {
        try Arrival
            .filter(Columns.tripID == id.description)
            .order(Columns.kilometer)
            .fetchAll(db)
    }

    static func fetchAllInOrder(_ db: Database) throws -> [Arrival] {
        try Arrival
            .order(Columns.kilometer)
            .fetchAll(db)
    }

    static func fetchAllInOrder(
        _ db: Database,
        journeyID: String
    ) throws -> [Arrival] {
        try Arrival
            .filter(sql: "journeyID = ?", arguments: [journeyID])
            .order(Columns.kilometer)
            .fetchAll(db)
    }

    static func fetchDecorated(_ db: Database) throws -> [Arrival] {
        try Arrival
            .filter(Columns.decoratedAt != nil)
            .order(Columns.decoratedAt)
            .fetchAll(db)
    }
}

public extension AppDatabase {
    func arrivals(forTrip id: Trip.ID) throws -> [Arrival] {
        try writer.read { db in
            try Arrival.fetchAll(db, forTrip: id)
        }
    }

    func arrivals() throws -> [Arrival] {
        try writer.read { db in
            try Arrival.fetchAllInOrder(db)
        }
    }

    func arrivals(journeyID: String) throws -> [Arrival] {
        try writer.read { db in
            try Arrival.fetchAllInOrder(db, journeyID: journeyID)
        }
    }

    func decoratedArrivals() throws -> [Arrival] {
        try writer.read { db in
            try Arrival.fetchDecorated(db)
        }
    }
}
