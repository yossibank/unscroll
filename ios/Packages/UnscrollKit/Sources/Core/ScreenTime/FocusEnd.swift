import Foundation

public enum FocusEnd {
    public static let toleranceSeconds: TimeInterval = 5

    public static func hasEnded(
        endsAt: Date?,
        at now: Date
    ) -> Bool {
        guard let endsAt else {
            return true
        }

        return now >= endsAt.addingTimeInterval(-toleranceSeconds)
    }

    public static func isLeftOver(
        endsAt: Date?,
        hasActiveTrip: Bool,
        at now: Date
    ) -> Bool {
        guard
            let endsAt,
            !hasActiveTrip
        else {
            return false
        }

        return hasEnded(endsAt: endsAt, at: now)
    }
}
