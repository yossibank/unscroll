import Foundation

public enum ShieldUnlock: Equatable, Sendable {
    case closed
    case startWaiting
    case keepWaiting
    case open

    public static let openUntilKey = "shield.openUntil"
    public static let pressedAtKey = "shield.pressedAt"
    public static let pressedTargetKey = "shield.pressedTarget"
    public static let waitSeconds: TimeInterval = 10
    public static let staleSeconds: TimeInterval = 60
    public static let openSeconds: TimeInterval = 60

    public init(
        strictness: Strictness,
        pressedAt: Date?,
        now: Date
    ) {
        switch strictness {
        case .gentle:
            self = .open

        case .strict:
            self = .closed

        case .normal:
            self = Self.waiting(pressedAt: pressedAt, now: now)
        }
    }

    private static func waiting(
        pressedAt: Date?,
        now: Date
    ) -> ShieldUnlock {
        guard let pressedAt else {
            return .startWaiting
        }

        let waited = now.timeIntervalSince(pressedAt)

        if waited < 0 || waited > staleSeconds {
            return .startWaiting
        } else if waited < waitSeconds {
            return .keepWaiting
        } else {
            return .open
        }
    }
}
