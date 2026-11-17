import CoreGraphics

extension JourneyMapGeometry {
    static let tohokuShinkansen = JourneyMapGeometry(
        spots: [
            "東京駅": CGPoint(x: 139.77, y: 35.68),
            "宇都宮駅": CGPoint(x: 139.9, y: 36.56),
            "仙台駅": CGPoint(x: 140.88, y: 38.26),
            "盛岡駅": CGPoint(x: 141.14, y: 39.7),
            "八戸駅": CGPoint(x: 141.43, y: 40.53),
            "新青森駅": CGPoint(x: 140.69, y: 40.83)
        ],
        labelOffsets: [
            "東京駅": CGSize(width: 0, height: -9),
            "宇都宮駅": CGSize(width: -18, height: -2),
            "仙台駅": CGSize(width: -18, height: -2),
            "盛岡駅": CGSize(width: -18, height: -2),
            "八戸駅": CGSize(width: 18, height: 0),
            "新青森駅": CGSize(width: -20, height: -2)
        ],
        longitude: 135.6,
        latitude: 41.6,
        longitudeSpan: 9.7,
        latitudeSpan: 6.7,
        backdrop: "map_tohokuShinkansen"
    )
}
