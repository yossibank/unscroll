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
}
