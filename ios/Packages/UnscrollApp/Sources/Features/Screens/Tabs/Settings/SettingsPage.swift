import DesignSystem
import SwiftUI

struct SettingsPage<Content: View>: View {
    let title: String
    let tint: Color
    let content: Content

    init(
        _ title: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .tracking(1)
                .padding(.horizontal, Spacing.small)
                .accessibilityAddTraits(.isHeader)

            content
        }
        .padding(.vertical, Spacing.small + 4)
        .padding(.horizontal, Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: UnevenRoundedRectangle(
            topLeadingRadius: 6,
            bottomLeadingRadius: 6,
            bottomTrailingRadius: 16,
            topTrailingRadius: 16
        ))
        .shadow(color: Palette.shadow, radius: 6, y: 2)
        .overlay(alignment: .topLeading) {
            UnevenRoundedRectangle(topLeadingRadius: 6, bottomLeadingRadius: 6)
                .fill(tint)
                .frame(width: 12, height: 44)
                .offset(x: -12, y: Spacing.small + 4)
                .accessibilityHidden(true)
        }
        .padding(.leading, Spacing.small + 4)
    }
}

#Preview {
    SettingsPage("旅で止めるもの", tint: Palette.coral) {
        Text("止めるアプリ")

        SettingsRule()

        Text("スクリーンタイムの許可")
    }
    .padding()
    .background(PaperBackdrop())
}
