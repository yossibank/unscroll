import Core
import DeviceActivity
import Foundation

final class UnscrollMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        EventLog.append("見張り：始まり（\(activity.rawValue)）", at: .now)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        finish(activity, checksOpenUntil: true)
        EventLog.append("見張り：終わり（\(activity.rawValue)）", at: .now)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)

        finish(activity, checksOpenUntil: false)
        EventLog.append("見張り：短い区切りの終わり（\(activity.rawValue)）", at: .now)
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)

        EventLog.append("見張り：区切りに届いた（\(event.rawValue)）", at: .now)
    }
}

private extension UnscrollMonitor {
    func finish(
        _ activity: DeviceActivityName,
        checksOpenUntil: Bool
    ) {
        switch activity.rawValue {
        case let name where ScreenTimeShared.isFocusActivity(name):
            let message = FocusShield.endTripIfFinished(activity: name, at: .now)
                ? "旅：終わった"
                : "旅：次の旅が続いているので止めたまま"

            EventLog.append(message, at: .now)

        case ScreenTimeShared.unlockActivityName:
            let result = FocusShield.reshieldIfTripContinues(
                at: .now,
                checksOpenUntil: checksOpenUntil
            )

            let message = switch result {
            case .done: "止めた画面：止め直した"
            case .stillOpen: "止めた画面：まだ開いている時間"
            case .tripEnded: "止めた画面：旅が終わっていた"
            }

            EventLog.append(message, at: .now)

        default:
            break
        }
    }
}
