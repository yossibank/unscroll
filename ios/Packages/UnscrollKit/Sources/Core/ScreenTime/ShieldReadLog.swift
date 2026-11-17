import Foundation

public enum ShieldReadLog {
    public enum Stage: String, Sendable {
        case openDatabase = "データベースを開く"
        case readCompanion = "相棒を読む"
        case readJourney = "旅を読む"
        case readProgress = "道のりを読む"
    }

    public static let failureKey = "shield.readLog.failure"
    public static let successKey = "shield.readLog.success"

    public static func recordFailure(
        at stage: Stage,
        error: any Error,
        date: Date = .now,
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) {
        defaults?.set("\(stamp(date)) \(stage.rawValue)で失敗（\(error)）", forKey: failureKey)
    }

    public static func recordSuccess(
        _ detail: String,
        date: Date = .now,
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) {
        defaults?.set("\(stamp(date)) \(detail)", forKey: successKey)
    }

    public static func lines(
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) -> [String] {
        let success = defaults?.string(forKey: successKey) ?? "なし"
        let failure = defaults?.string(forKey: failureKey) ?? "なし"
        return ["止めた画面の最後の失敗：\(failure)", "止めた画面の最後の成功：\(success)"]
    }

    public static func clear(
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) {
        defaults?.removeObject(forKey: failureKey)
        defaults?.removeObject(forKey: successKey)
    }
}

private extension ShieldReadLog {
    static func stamp(_ date: Date) -> String {
        date.formatted(.dateTime.month().day().hour().minute().second())
    }
}
