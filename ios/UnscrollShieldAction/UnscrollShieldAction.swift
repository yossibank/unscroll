import Core
import Foundation
import ManagedSettings

final class UnscrollShieldAction: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(respond(to: action, for: .application(application)))
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(respond(to: action, for: .webDomain(webDomain)))
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(respond(to: action, for: nil))
    }
}

private extension UnscrollShieldAction {
    func respond(
        to action: ShieldAction,
        for target: FocusShield.Target?
    ) -> ShieldActionResponse {
        switch action {
        case .primaryButtonPressed:
            EventLog.append("止めた画面：集中に戻る")
            return .close

        case .secondaryButtonPressed:
            guard let target else {
                EventLog.append("止めた画面：カテゴリでは開けない")
                return .defer
            }

            let message = switch FocusShield.press(target, at: .now) {
            case .startWaiting: "止めた画面：10 秒待ち始めた"
            case .keepWaiting: "止めた画面：まだ 10 秒たっていない"
            case .open: "止めた画面：1 分開いた"
            }

            EventLog.append(message)
            return .defer

        @unknown default:
            return .close
        }
    }
}
