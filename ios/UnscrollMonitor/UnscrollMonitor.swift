import Core
import DeviceActivity
import ManagedSettings

final class UnscrollMonitor: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(
        named: ManagedSettingsStore.Name(ScreenTimeShared.focusStoreName)
    )

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        EventLog.append("見張り：始まり（\(activity.rawValue)）")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        if activity.rawValue == ScreenTimeShared.focusActivityName {
            store.clearAllSettings()
        }

        EventLog.append("見張り：終わり（\(activity.rawValue)）")
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        if activity.rawValue == ScreenTimeShared.focusActivityName {
            store.clearAllSettings()
        }

        EventLog.append("見張り：短い旅の終わり（\(activity.rawValue)）")
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        EventLog.append("見張り：区切りに届いた（\(event.rawValue)）")
    }
}
