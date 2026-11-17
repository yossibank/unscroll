import DesignSystem
import SwiftUI

struct JourneyMapPaper: View {
    let model: JourneyMapModel

    var body: some View {
        TapedPaper {
            map
        }
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
