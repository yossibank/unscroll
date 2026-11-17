import CoreGraphics

extension JourneyMapGeometry {
    static let hokkaido = JourneyMapGeometry(
        spots: [
            "函館": CGPoint(x: 140.73, y: 41.77),
            "大沼": CGPoint(x: 140.66, y: 41.93),
            "洞爺湖": CGPoint(x: 140.82, y: 42.545),
            "小樽": CGPoint(x: 141.0, y: 43.19),
            "札幌": CGPoint(x: 141.35, y: 43.06),
            "富良野": CGPoint(x: 142.38, y: 43.34),
            "旭川": CGPoint(x: 142.37, y: 43.77)
        ],
        labelOffsets: [
            "函館": CGSize(width: 17, height: 0),
            "大沼": CGSize(width: -16, height: -1),
            "洞爺湖": CGSize(width: -17, height: 0),
            "小樽": CGSize(width: -14, height: -8),
            "札幌": CGSize(width: 14, height: 8),
            "富良野": CGSize(width: 17, height: 0),
            "旭川": CGSize(width: 14, height: -1)
        ],
        longitude: 139.2,
        latitude: 44.1,
        longitudeSpan: 4.6,
        latitudeSpan: 2.7,
        backdrop: "map_hokkaido"
    )
}
