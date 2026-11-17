import Core
import DesignSystem
import SwiftUI
import Testing

@MainActor
struct TripSceneryTests {
    @Test(arguments: [
        CGSize(width: 0, height: 0),
        CGSize(width: 390, height: 0)
    ])
    func drawsWithoutHeight(size: CGSize) throws {
        let landmark = try #require(Journey.tokyoToKyoto.landmarks.first)

        let scenery = TripScenery(
            landmark: landmark,
            period: .day,
            isMoving: false
        )
        .frame(width: size.width, height: size.height)

        _ = ImageRenderer(content: scenery).uiImage
    }
}
