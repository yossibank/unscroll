import Core
import DesignSystem
import Foundation
import ManagedSettings
import ManagedSettingsUI
import Store
import UIKit

final class UnscrollShield: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration(target: application.token.map { .application($0) })
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        makeConfiguration(target: category.token.map { .category($0) })
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration(target: webDomain.token.map { .webDomain($0) })
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        makeConfiguration(target: webDomain.token.map { .webDomain($0) })
    }
}

private extension UnscrollShield {
    static let iconSide: CGFloat = 96

    func makeConfiguration(target: FocusShield.Target?) -> ShieldConfiguration {
        let night = UIColor(red: 0.11, green: 0.15, blue: 0.28, alpha: 1)
        let coral = UIColor(red: 1, green: 0.48, blue: 0.35, alpha: 1)
        let soft = UIColor(white: 0.8, alpha: 1)
        let database = try? AppDatabase.appGroupReader()
        let companion = try? database?.companion()
        let progress = try? database?.journeyProgress(at: .now)

        let letter = ShieldLetter(
            companionName: companion?.name,
            journey: .tokyoToKyoto,
            kilometers: progress?.kilometers
        )

        let secondary = secondaryLabel(for: target).map {
            ShieldConfiguration.Label(text: $0, color: soft)
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: night,
            icon: icon(for: companion),
            title: ShieldConfiguration.Label(text: letter.title, color: .white),
            subtitle: ShieldConfiguration.Label(text: letter.body, color: soft),
            primaryButtonLabel: ShieldConfiguration.Label(text: "旅に戻る", color: .white),
            primaryButtonBackgroundColor: coral,
            secondaryButtonLabel: secondary
        )
    }

    func icon(for companion: Companion?) -> UIImage? {
        let art = companion.flatMap {
            CompanionSticker.uiImage(of: $0, pose: .wave, side: Self.iconSide)
        }

        return art ?? UIImage(systemName: "envelope.fill")
    }

    func secondaryLabel(for target: FocusShield.Target?) -> String? {
        switch FocusShield.tripStrictness {
        case .gentle:
            "1 分だけ開く"

        case .normal:
            FocusShield.isWaiting(for: target, at: .now) ? "10 秒後にもう一度押してね" : "10 秒待って開く"

        case .strict:
            nil
        }
    }
}
