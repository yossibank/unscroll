import CoreGraphics

extension JourneyMapGeometry {
    static let tokaido = JourneyMapGeometry(
        spots: [
            "日本橋": CGPoint(x: 139.77, y: 35.68),
            "芦ノ湖": CGPoint(x: 139.02, y: 35.2),
            "三保の松原": CGPoint(x: 138.52, y: 35.0),
            "浜名湖": CGPoint(x: 137.6, y: 34.75),
            "名古屋城": CGPoint(x: 136.9, y: 35.18),
            "琵琶湖": CGPoint(x: 135.98, y: 35.08),
            "清水寺": CGPoint(x: 135.78, y: 35.0)
        ],
        labelOffsets: [
            "日本橋": CGSize(width: 0, height: -9),
            "芦ノ湖": CGSize(width: 2, height: -9),
            "三保の松原": CGSize(width: 0, height: 10),
            "浜名湖": CGSize(width: 0, height: 10),
            "名古屋城": CGSize(width: 2, height: -9),
            "琵琶湖": CGSize(width: 14, height: -6),
            "清水寺": CGSize(width: -2, height: 10)
        ],
        longitude: 135.3,
        latitude: 36.45,
        longitudeSpan: 5.1,
        latitudeSpan: 2.2,
        backdrop: "map_tokaido"
    )
}
