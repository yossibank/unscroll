import Core
import ManagedSettings
import ManagedSettingsUI
import UIKit

final class UnscrollShield: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration(name: application.localizedDisplayName)
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        makeConfiguration(name: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration(name: webDomain.domain)
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        makeConfiguration(name: webDomain.domain)
    }
}

private extension UnscrollShield {
    func makeConfiguration(name: String?) -> ShieldConfiguration {
        let night = UIColor(red: 0.11, green: 0.15, blue: 0.28, alpha: 1)
        let coral = UIColor(red: 1, green: 0.48, blue: 0.35, alpha: 1)
        let soft = UIColor(white: 0.8, alpha: 1)
        let subtitle = "\(name ?? "このアプリ")は、集中が終わるまで止めています。"
        let secondary = FocusShield.pressedAt == nil ? "10 秒待って開く" : "10 秒後にもう一度押してね"

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: night,
            icon: UIImage(systemName: "hare.fill"),
            title: ShieldConfiguration.Label(text: "あと少し、いっしょに耐えて！", color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitle, color: soft),
            primaryButtonLabel: ShieldConfiguration.Label(text: "集中に戻る", color: .white),
            primaryButtonBackgroundColor: coral,
            secondaryButtonLabel: ShieldConfiguration.Label(text: secondary, color: soft)
        )
    }
}
