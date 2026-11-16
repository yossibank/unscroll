import GRDB

enum MigrationV006 {
    static let defaultJourneyID = "tokaido"

    static func migrate(_ db: Database) throws {
        for table in ["trip", "arrival"] {
            try db.alter(table: table) { table in
                table.add(column: "journeyID", .text).notNull().defaults(to: defaultJourneyID)
            }
        }

        try db.create(table: "currentJourney") { table in
            table.primaryKey("id", .integer).check { $0 == 1 }
            table.column("journeyID", .text).notNull()
        }
    }
}
