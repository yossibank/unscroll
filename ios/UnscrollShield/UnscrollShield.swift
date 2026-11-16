import Core
import DesignSystem
import Foundation
import ManagedSettings
import ManagedSettingsUI
import Store
import SwiftUI
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
    static let envelopeColumns = 14
    static let envelopeRows = 10

    func makeConfiguration(target: FocusShield.Target?) -> ShieldConfiguration {
        let paper = UIColor(Palette.paper)
        let ink = UIColor(Palette.ink)
        let muted = UIColor(Palette.muted)
        let teal = UIColor(Palette.teal)
        let now = Date.now
        let database = try? AppDatabase.appGroupReader()
        let companion = try? database?.companion()
        let progress = try? database?.journeyProgress(at: now)

        let letter = ShieldLetter(
            companionName: companion?.name,
            journey: .tokyoToKyoto,
            kilometers: progress?.kilometers,
            remainingMinutes: progress?.activeTrip?.remainingMinutes(at: now)
        )

        let secondary = secondaryLabel(for: target).map {
            ShieldConfiguration.Label(text: $0, color: teal)
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialLight,
            backgroundColor: paper,
            icon: icon(for: companion),
            title: ShieldConfiguration.Label(text: letter.title, color: ink),
            subtitle: ShieldConfiguration.Label(text: letter.body, color: muted),
            primaryButtonLabel: ShieldConfiguration.Label(text: "旅に戻る", color: .white),
            primaryButtonBackgroundColor: teal,
            secondaryButtonLabel: secondary
        )
    }

    func icon(for companion: Companion?) -> UIImage? {
        guard
            let companion,
            let art = CompanionSticker.uiImage(of: companion, pose: .wave, side: Self.iconSide)
        else {
            return UIImage(systemName: "envelope.fill")
        }

        let size = CGSize(width: Self.iconSide, height: Self.iconSide)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            art.draw(in: CGRect(origin: .zero, size: size))
            drawEnvelope(in: context.cgContext)
        }
    }

    func drawEnvelope(in context: CGContext) {
        let unit = (Self.iconSide / 40).rounded(.down)
        let origin = CGPoint(
            x: Self.iconSide - CGFloat(Self.envelopeColumns + 2) * unit,
            y: Self.iconSide - CGFloat(Self.envelopeRows + 1) * unit
        )
        let outline = UIColor(red: 74 / 255, green: 52 / 255, blue: 40 / 255, alpha: 1)
        let face = UIColor(red: 250 / 255, green: 244 / 255, blue: 228 / 255, alpha: 1)
        let seal = UIColor(Palette.coral)

        for row in 0..<Self.envelopeRows {
            for column in 0..<Self.envelopeColumns {
                let color = envelopeColor(
                    column: column,
                    row: row,
                    outline: outline,
                    face: face,
                    seal: seal
                )
                let rect = CGRect(
                    x: origin.x + CGFloat(column) * unit,
                    y: origin.y + CGFloat(row) * unit,
                    width: unit,
                    height: unit
                )

                context.setFillColor(color.cgColor)
                context.fill(rect)
            }
        }
    }

    func envelopeColor(
        column: Int,
        row: Int,
        outline: UIColor,
        face: UIColor,
        seal: UIColor
    ) -> UIColor {
        let last = Self.envelopeColumns - 1
        let isEdge = row == 0 || row == Self.envelopeRows - 1 || column == 0 || column == last
        let isFlap = row <= 5 && (column == row || column == last - row)
        let isSeal = (6...7).contains(column) && (5...6).contains(row)

        if isEdge || isFlap {
            return outline
        }

        return isSeal ? seal : face
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
