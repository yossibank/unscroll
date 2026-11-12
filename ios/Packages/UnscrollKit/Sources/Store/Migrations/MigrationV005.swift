import GRDB

enum MigrationV005 {
    static func migrate(_ db: Database) throws {
        try db.create(table: "companion") { table in
            table.primaryKey("id", .integer).check { $0 == 1 }
            table.column("species", .text).notNull()
            table.column("coat", .text).notNull()
            table.column("name", .text).notNull()
        }
    }
}
