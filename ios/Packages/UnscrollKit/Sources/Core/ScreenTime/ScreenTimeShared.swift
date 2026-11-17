public enum ScreenTimeShared {
    public static let appGroup = "group.com.yossibank.unscroll"
    public static let selectionKey = "screenTime.selection"
    public static let focusStoreName = "focus"
    public static let focusActivityName = "focus"
    public static let focusEndsAtKey = "focus.endsAt"
    public static let unlockActivityName = "unlock"
    public static let usageActivityName = "usage"
    public static let usageThresholdMinutes = [1, 5, 15]
    public static let reportContextName = "todayUsage"

    public static func usageEventName(minutes: Int) -> String {
        "usage.\(minutes)m"
    }
}
