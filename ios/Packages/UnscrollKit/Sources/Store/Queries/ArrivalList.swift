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
}

public extension AppDatabase {
    func arrivals(forTrip id: Trip.ID) throws -> [Arrival] {
        try writer.read { db in
            try Arrival.fetchAll(db, forTrip: id)
        }
    }
}
