import DesignSystem
import SwiftUI

struct AppSetDeleteSheet: View {
    let name: String
    let summary: String
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            MaskingTape(tint: Palette.coral)
                .rotationEffect(.degrees(-4))

            JournalTitle("「\(name)」を消す？", note: "選んだアプリも、いっしょに消えます")

            HStack(spacing: Spacing.small + 4) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Palette.coral, in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(Palette.ink)

                    Text(summary)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.muted)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)

                Spacer(minLength: 0)
            }
            .padding(Spacing.small + 4)
            .background(Palette.card, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Palette.coral.opacity(0.4),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                    )
            }

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Button {
                    onDelete()
                } label: {
                    Label("消す", systemImage: "trash.fill")
                }
                .buttonStyle(.pill)

                Button("やめる") {
                    onCancel()
                }
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.large)
        .padding(.bottom, Spacing.small)
        .background(PaperBackdrop())
    }
}
