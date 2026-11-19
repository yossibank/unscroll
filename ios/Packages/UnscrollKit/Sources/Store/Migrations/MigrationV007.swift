import GRDB

enum MigrationV007 {
    static func migrate(_ db: Database) throws {
        try db.alter(table: "trip") { table in
            table.add(column: "isPractice", .boolean).notNull().defaults(to: false)
        }
    }
}
