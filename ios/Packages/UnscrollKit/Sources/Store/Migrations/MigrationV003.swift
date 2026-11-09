import GRDB

enum MigrationV003 {
    static func migrate(_ db: Database) throws {
        try db.create(table: "arrival") { table in
            table.primaryKey("landmarkName", .text)
            table.column("kilometer", .integer).notNull()
            table.column("tripID", .text)
                .notNull()
                .references("trip", onDelete: .cascade)
            table.column("arrivedAt", .datetime).notNull()
        }
    }
}
