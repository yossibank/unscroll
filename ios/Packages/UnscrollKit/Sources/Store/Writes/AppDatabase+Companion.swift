import Core
import GRDB

public extension AppDatabase {
    func companion() throws -> Companion? {
        try writer.read { db in
            try Companion.fetchOne(db, key: Companion.rowID)
        }
    }

    func saveCompanion(_ companion: Companion) throws {
        try writer.write { db in
            try companion.save(db)
        }
    }
}
