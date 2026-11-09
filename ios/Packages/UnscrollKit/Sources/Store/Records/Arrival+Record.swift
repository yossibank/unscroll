import Core
import Foundation
import GRDB

extension Arrival: FetchableRecord, PersistableRecord {
    public enum Columns: String, ColumnExpression {
        case landmarkName
        case kilometer
        case tripID
        case arrivedAt
    }

    public static var databaseTableName: String {
        "arrival"
    }

    public init(row: Row) throws {
        let text: String = row[Columns.tripID]

        guard let tripID = Trip.ID(text) else {
            throw DatabaseError(message: "Invalid trip id: \(text)")
        }

        self.init(
            landmark: Landmark(
                name: row[Columns.landmarkName],
                kilometer: row[Columns.kilometer]
            ),
            tripID: tripID,
            arrivedAt: row[Columns.arrivedAt]
        )
    }

    public func encode(to container: inout PersistenceContainer) throws {
        container[Columns.landmarkName] = landmark.name
        container[Columns.kilometer] = landmark.kilometer
        container[Columns.tripID] = tripID.description
        container[Columns.arrivedAt] = arrivedAt
    }
}
