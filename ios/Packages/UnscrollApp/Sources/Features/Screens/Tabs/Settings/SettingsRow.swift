import DesignSystem
import SwiftUI

struct SettingsRow<Trailing: View>: View {
    let title: String
    let detail: String?
    let systemImage: String
    let tint: Color
    let trailing: Trailing

    init(
        title: String,
        detail: String? = nil,
        systemImage: String,
        tint: Color,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
        self.tint = tint
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: Spacing.small + 4) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(tint, in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Palette.ink)

                if let detail {
                    Text(detail)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Palette.muted)
                }
            }

            Spacer(minLength: Spacing.small)

            HStack(spacing: Spacing.small) {
                trailing
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(Palette.muted)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .padding(Spacing.small)
        .frame(minHeight: 52)
        .contentShape(.rect)
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsRow(
            title: "止めるアプリ",
            systemImage: "hand.raised.fill",
            tint: Palette.coral
        ) {
            Text("未選択")
        }

        SettingsRow(
            title: "ふつう",
            detail: "10 秒待つと開けます",
            systemImage: "hourglass",
            tint: Palette.sun
        ) {
            EmptyView()
        }
    }
    .roundedCard(padding: Spacing.small)
    .padding()
    .background(PaperBackdrop())
}
