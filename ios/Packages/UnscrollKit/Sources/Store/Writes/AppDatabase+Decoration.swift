import Core
import Foundation
import GRDB

public extension AppDatabase {
    func setDecorated(
        _ isDecorated: Bool,
        landmark: Landmark,
        at now: Date
    ) throws {
        try writer.write { db in
            guard var arrival = try Arrival.fetchOne(db, key: landmark.name) else {
                return
            }

            guard arrival.isDecorated != isDecorated else {
                return
            }

            arrival.decoratedAt = isDecorated ? now : nil
            try arrival.update(db)
        }
    }
}
