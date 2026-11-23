import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct JourneyNote: View {
    let usage: TodayUsage

    var body: some View {
        let kilometers = Int(usage.total / 60) * Trip.kilometersPerMinute

        HStack(spacing: Spacing.small) {
            Image(systemName: "figure.walk")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Palette.teal, in: Circle())

            Text(usage.journeyText(kilometers))
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.tealDeep)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
        }
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.tealSoft, in: .rect(cornerRadius: 16))
    }
}
