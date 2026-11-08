import Foundation

public enum EventLog {
    public static let key = "screenTime.eventLog"
    public static let limit = 50

    public static func append(
        _ message: String,
        at date: Date = .now,
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) {
        guard let defaults else {
            return
        }

        let time = date.formatted(.dateTime.month().day().hour().minute().second())
        let lines = ["\(time) \(message)"] + (defaults.stringArray(forKey: key) ?? [])

        defaults.set(Array(lines.prefix(limit)), forKey: key)
    }

    public static func lines(
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) -> [String] {
        defaults?.stringArray(forKey: key) ?? []
    }

    public static func clear(
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) {
        defaults?.removeObject(forKey: key)
    }
}
