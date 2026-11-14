import Core
import DeviceActivity
import Foundation

final class UnscrollMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        EventLog.append("見張り：始まり（\(activity.rawValue)）")
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        finish(activity)
        EventLog.append("見張り：終わり（\(activity.rawValue)）")
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        finish(activity)
        EventLog.append("見張り：短い区切りの終わり（\(activity.rawValue)）")
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        EventLog.append("見張り：区切りに届いた（\(event.rawValue)）")
    }
}

private extension UnscrollMonitor {
    func finish(_ activity: DeviceActivityName) {
        switch activity.rawValue {
        case ScreenTimeShared.focusActivityName:
            FocusShield.endTrip()

        case ScreenTimeShared.unlockActivityName:
            let message = switch FocusShield.reshieldIfTripContinues(at: .now) {
            case .done: "止めた画面：止め直した"
            case .stillOpen: "止めた画面：まだ開いている時間"
            case .tripEnded: "止めた画面：旅が終わっていた"
            }

            EventLog.append(message)

        default:
            break
        }
    }
}
