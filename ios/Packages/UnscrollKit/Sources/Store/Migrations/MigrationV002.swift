import GRDB

enum MigrationV002 {
    static func migrate(_ db: Database) throws {
        try db.create(table: "trip") { table in
            table.primaryKey("id", .text)
            table.column("startedAt", .datetime).notNull()
            table.column("plannedMinutes", .integer).notNull().check { $0 > 0 }
            table.column("endedAt", .datetime)
        }
    }
}
