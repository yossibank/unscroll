import DesignSystem
import SwiftUI

struct UsageFact: View {
    let value: String
    let note: String

    init(
        _ value: String,
        note: String
    ) {
        self.value = value
        self.note = note
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.heavy))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(note)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Palette.muted)
        }
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
        .background(Palette.coralSoft, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Palette.coral.opacity(0.4),
                    style: StrokeStyle(lineWidth: 2, dash: [4, 4])
                )
        }
    }
}
