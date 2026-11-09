import GRDB

enum MigrationV004 {
    static func migrate(_ db: Database) throws {
        try db.alter(table: "arrival") { table in
            table.add(column: "decoratedAt", .datetime)
        }
    }
}
