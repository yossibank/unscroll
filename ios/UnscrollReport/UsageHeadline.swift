import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct UsageHeadline: View {
    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            UsageTotal(usage: usage)

            Label(comparison.text, systemImage: comparison.symbol)
                .font(.caption.weight(.heavy))
                .foregroundStyle(comparison.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.small + 4)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
                .background(comparison.tint.opacity(0.12), in: .rect(cornerRadius: 12))
        }
    }
}

private extension UsageHeadline {
    var comparison: (text: String, symbol: String, tint: Color) {
        usage.comparison ?? ("昨日の記録はまだありません", "clock", Palette.muted)
    }
}
