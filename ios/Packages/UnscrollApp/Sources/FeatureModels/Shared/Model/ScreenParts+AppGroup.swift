import Store

public extension ScreenParts {
    static func appGroup(clock: ScreenClock) throws -> ScreenParts {
        let database = try AppDatabase.appGroup()
        return ScreenParts(database: database, clock: clock)
    }

    static func suspendDatabase() {
        AppDatabase.suspend()
    }

    static func resumeDatabase() {
        AppDatabase.resume()
    }
}
