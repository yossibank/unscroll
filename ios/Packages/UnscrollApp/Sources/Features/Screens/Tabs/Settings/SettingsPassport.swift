import Core
import DesignSystem
import SwiftUI

struct SettingsPassport: View {
    let companion: Companion?
    let kilometers: Int?

    var body: some View {
        HStack(spacing: Spacing.small + 4) {
            photo

            VStack(alignment: .leading, spacing: 2) {
                Text("旅券　相棒")
                    .font(.caption2.weight(.heavy))
                    .tracking(2)
                    .opacity(0.8)

                Text(companion?.name ?? "相棒を選ぶ")
                    .journalTitleFont(size: 24)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(note)
                    .font(.caption.weight(.bold))
                    .opacity(0.85)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 0)

            if kilometers != nil {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.heavy))
                    .opacity(0.7)
            }
        }
        .foregroundStyle(.white)
        .padding(Spacing.medium)
        .background(alignment: .topTrailing) {
            seal
                .padding(.top, Spacing.small + 4)
                .padding(.trailing, Spacing.large + 4)
        }
        .background(
            LinearGradient(
                colors: [Palette.tealDeep, Palette.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .shadow(color: Palette.tealDeep.opacity(0.3), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityTitle)
    }
}

private extension SettingsPassport {
    var photo: some View {
        Group {
            if let companion {
                CompanionSticker(
                    companion: companion,
                    pose: .walk,
                    size: 52,
                    breathes: false
                )
            } else {
                Image(systemName: "pawprint.fill")
                    .font(.title2)
                    .foregroundStyle(Palette.sunDeep)
            }
        }
        .frame(width: 60, height: 68)
        .background(Palette.sunSoft, in: .rect(cornerRadius: 2))
        .padding(4)
        .background(.white, in: .rect(cornerRadius: 4))
        .rotationEffect(.degrees(-3))
    }

    var seal: some View {
        Text("旅の\n相棒")
            .font(.system(size: 9, weight: .heavy))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .frame(width: 52, height: 52)
            .overlay {
                Circle()
                    .strokeBorder(.white.opacity(0.6), lineWidth: 2)
            }
            .rotationEffect(.degrees(12))
            .opacity(0.5)
            .accessibilityHidden(true)
    }
}

private extension SettingsPassport {
    var note: String {
        guard let companion else {
            return "いっしょに旅する相棒"
        }

        guard let kilometers else {
            return companion.kindLabel
        }

        return "\(companion.kindLabel)・いっしょに \(kilometers.formatted()) km"
    }

    var accessibilityTitle: String {
        guard let companion else {
            return "相棒を選ぶ"
        }

        return "相棒、\(companion.name)、\(note)"
    }
}
