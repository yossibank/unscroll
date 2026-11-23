import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct UsageTotal: View {
    let usage: TodayUsage

    var body: some View {
        let parts = Duration.seconds(usage.total).components
        let hours = parts.seconds / 3600
        let minutes = (parts.seconds % 3600) / 60

        HStack(alignment: .lastTextBaseline, spacing: 2) {
            if hours > 0 {
                Text("\(hours)")
                    .font(.system(size: 36, weight: .heavy))

                Text("時間")
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(Palette.muted)
                    .padding(.trailing, 4)
            }

            Text("\(minutes)")
                .font(.system(size: 36, weight: .heavy))

            Text("分")
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.muted)
        }
        .monospacedDigit()
        .accessibilityElement(children: .combine)
    }
}
