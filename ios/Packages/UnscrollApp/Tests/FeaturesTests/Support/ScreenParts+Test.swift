import FeatureModels
import Foundation
import Store

extension ScreenParts {
    static func system(_ database: AppDatabase) -> ScreenParts {
        ScreenParts(database: database, clock: .system)
    }

    static func fixed(
        _ database: AppDatabase,
        at date: Date
    ) -> ScreenParts {
        ScreenParts(database: database, clock: .fixed(date))
    }
}
