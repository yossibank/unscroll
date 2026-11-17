import CoreGraphics
import DesignSystem

struct JourneyMapGeometry {
    let spots: [String: CGPoint]
    let labelOffsets: [String: CGSize]
    let longitude: Double
    let latitude: Double
    let longitudeSpan: Double
    let latitudeSpan: Double
    let backdrop: String
}

extension JourneyMapGeometry {
    static let all: [String: JourneyMapGeometry] = [
        "tokaido": .tokaido,
        "tohokuShinkansen": .tohokuShinkansen,
        "okinawa": .okinawa,
        "worldHeritage": .worldHeritage,
        "osakaHakata": .osakaHakata,
        "hokkaido": .hokkaido
    ]

    static func `for`(_ journeyID: String) -> JourneyMapGeometry? {
        all[journeyID]
    }

    func pixel(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: (point.x - longitude) / longitudeSpan * MapBackdrop.width,
            y: (latitude - point.y) / latitudeSpan * MapBackdrop.height
        )
    }
}
