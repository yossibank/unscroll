public enum UsageSort: String, CaseIterable, Sendable {
    case time
    case pickups
    case perPickup
    case notifications
}

public extension UsageSort {
    var reportContextName: String {
        "todayUsage.\(rawValue)"
    }
}
