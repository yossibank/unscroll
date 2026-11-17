import DesignSystem
import SwiftUI

struct JourneyMapPaper: View {
    let model: JourneyMapModel

    var body: some View {
        map
            .clipShape(.rect(cornerRadius: 4))
            .padding(Spacing.small)
            .background(Palette.card, in: .rect(cornerRadius: 6))
            .shadow(color: Palette.ink.opacity(0.14), radius: 8, y: 6)
            .overlay(alignment: .topLeading) {
                MaskingTape(tint: Palette.coral)
                    .rotationEffect(.degrees(-6))
                    .offset(x: Spacing.large, y: -10)
            }
            .overlay(alignment: .bottomTrailing) {
                MaskingTape(tint: Palette.sky)
                    .rotationEffect(.degrees(-4))
                    .offset(x: -Spacing.large, y: 10)
            }
            .rotationEffect(.degrees(-1))
    }
}

private extension JourneyMapPaper {
    @ViewBuilder
    var map: some View {
        if let geometry = JourneyMapGeometry.for(model.journey.id) {
            JourneyMapCanvas(
                journey: model.journey,
                geometry: geometry,
                kilometers: model.kilometers,
                companion: model.companion
            )
        } else {
            Rectangle()
                .fill(Palette.paperDeep)
                .aspectRatio(MapBackdrop.aspectRatio, contentMode: .fit)
        }
    }
}
