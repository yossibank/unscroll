import DesignSystem
import FamilyControls
import SwiftUI

struct AppRow<Icon: View>: View {
    let name: String
    let value: String
    let ratio: Double
    let tint: Color

    @ViewBuilder let icon: Icon

    var body: some View {
        HStack(spacing: Spacing.small) {
            icon

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: Spacing.small) {
                    Text(name)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)

                    Text(value)
                        .foregroundStyle(Palette.muted)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .font(.footnote.weight(.bold))

                GeometryReader { proxy in
                    Capsule()
                        .fill(Palette.paperDeep)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(tint)
                                .frame(width: proxy.size.width * ratio)
                        }
                }
                .frame(height: 8)
            }
        }
    }
}
