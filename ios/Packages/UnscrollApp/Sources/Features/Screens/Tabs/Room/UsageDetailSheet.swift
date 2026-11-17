import DesignSystem
import SwiftUI

struct UsageDetailSheet: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: Spacing.medium) {
            HStack {
                Text("今日のスマホ")
                    .font(.title3.weight(.heavy))

                Spacer()

                Button("閉じる") {
                    onClose()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.muted)
            }

            UsageReportView(isDetailed: true)
                .frame(maxHeight: .infinity)
        }
        .padding(Spacing.medium)
        .padding(.top, Spacing.small)
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .background(Palette.paper)
    }
}
