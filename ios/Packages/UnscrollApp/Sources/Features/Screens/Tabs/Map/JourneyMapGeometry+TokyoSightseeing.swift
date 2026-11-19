import CoreGraphics

extension JourneyMapGeometry {
    static let tokyoSightseeing = JourneyMapGeometry(
        spots: [
            "東京駅": CGPoint(x: 139.767, y: 35.681),
            "皇居": CGPoint(x: 139.754, y: 35.685),
            "浅草": CGPoint(x: 139.797, y: 35.711),
            "東京スカイツリー": CGPoint(x: 139.811, y: 35.710),
            "お台場": CGPoint(x: 139.775, y: 35.627),
            "東京タワー": CGPoint(x: 139.745, y: 35.659)
        ],
        labelOffsets: [
            "東京駅": CGSize(width: 8, height: 10),
            "皇居": CGSize(width: -12, height: -9),
            "浅草": CGSize(width: -10, height: -9),
            "東京スカイツリー": CGSize(width: 14, height: 10),
            "お台場": CGSize(width: 2, height: 10),
            "東京タワー": CGSize(width: -4, height: 10)
        ],
        longitude: 139.66,
        latitude: 35.75,
        longitudeSpan: 0.34,
        latitudeSpan: 0.1816,
        backdrop: "map_tokyoSightseeing"
    )
}
