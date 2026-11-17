import CoreGraphics

extension JourneyMapGeometry {
    static let shikoku = JourneyMapGeometry(
        spots: [
            "鳴門の渦潮": CGPoint(x: 134.6, y: 34.19),
            "桂浜": CGPoint(x: 133.57, y: 33.51),
            "四万十川": CGPoint(x: 132.95, y: 33.01),
            "道後温泉": CGPoint(x: 132.786, y: 33.852),
            "しまなみ海道": CGPoint(x: 133.09, y: 34.24),
            "金刀比羅宮": CGPoint(x: 133.81, y: 34.19)
        ],
        labelOffsets: [
            "鳴門の渦潮": CGSize(width: -4, height: 10),
            "桂浜": CGSize(width: 0, height: 10),
            "四万十川": CGSize(width: 0, height: 10),
            "道後温泉": CGSize(width: 0, height: 10),
            "しまなみ海道": CGSize(width: 0, height: -9),
            "金刀比羅宮": CGSize(width: 0, height: 10)
        ],
        longitude: 131.8,
        latitude: 34.9,
        longitudeSpan: 3.3,
        latitudeSpan: 2.2,
        backdrop: "map_shikoku"
    )
}
