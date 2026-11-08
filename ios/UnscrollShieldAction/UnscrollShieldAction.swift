import Core
import ManagedSettings

final class UnscrollShieldAction: ShieldActionDelegate {
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(respond(to: action))
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(respond(to: action))
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        completionHandler(respond(to: action))
    }
}

private extension UnscrollShieldAction {
    func respond(to action: ShieldAction) -> ShieldActionResponse {
        switch action {
        case .primaryButtonPressed:
            EventLog.append("止めた画面：集中に戻る")
            return .close

        case .secondaryButtonPressed:
            EventLog.append("止めた画面：1 分だけ開く（試作では開かない）")
            return .defer

        @unknown default:
            return .close
        }
    }
}
