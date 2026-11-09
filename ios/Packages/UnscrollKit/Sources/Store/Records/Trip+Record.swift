import Core
import Foundation
import GRDB

extension Trip: FetchableRecord, PersistableRecord {
    public enum Columns: String, ColumnExpression {
        case id
        case startedAt
        case plannedMinutes
        case endedAt
    }

    public static var databaseTableName: String {
        "trip"
    }

    public init(row: Row) throws {
        let text: String = row[Columns.id]

        guard let id = ID(text) else {
            throw DatabaseError(message: "Invalid trip id: \(text)")
        }

        self.init(
            id: id,
            startedAt: row[Columns.startedAt],
            plannedMinutes: row[Columns.plannedMinutes],
            endedAt: row[Columns.endedAt]
        )
    }

    public func encode(to container: inout PersistenceContainer) throws {
        container[Columns.id] = id.description
        container[Columns.startedAt] = startedAt
        container[Columns.plannedMinutes] = plannedMinutes
        container[Columns.endedAt] = endedAt
    }
}
