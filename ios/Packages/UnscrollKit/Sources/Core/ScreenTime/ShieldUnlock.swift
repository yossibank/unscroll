import Foundation

public enum ShieldUnlock: Equatable, Sendable {
    case startWaiting
    case keepWaiting
    case open

    public static let openUntilKey = "shield.openUntil"
    public static let pressedAtKey = "shield.pressedAt"
    public static let waitSeconds: TimeInterval = 10
    public static let openSeconds: TimeInterval = 60

    public init(
        pressedAt: Date?,
        now: Date
    ) {
        guard let pressedAt else {
            self = .startWaiting
            return
        }

        let waited = now.timeIntervalSince(pressedAt)

        if waited < 0 {
            self = .startWaiting
        } else if waited < Self.waitSeconds {
            self = .keepWaiting
        } else {
            self = .open
        }
    }
}
