import CoreGraphics

extension JourneyMapGeometry {
    static let osakaHakata = JourneyMapGeometry(
        spots: [
            "道頓堀": CGPoint(x: 135.5, y: 34.668),
            "神戸の南京町": CGPoint(x: 135.19, y: 34.69),
            "明石": CGPoint(x: 135.0, y: 34.65),
            "岡山": CGPoint(x: 133.92, y: 34.66),
            "尾道": CGPoint(x: 133.2, y: 34.41),
            "広島": CGPoint(x: 132.46, y: 34.39),
            "博多の屋台": CGPoint(x: 130.41, y: 33.59)
        ],
        labelOffsets: [
            "道頓堀": CGSize(width: 3, height: 12),
            "神戸の南京町": CGSize(width: -20, height: 12),
            "明石": CGSize(width: -18, height: -9),
            "岡山": CGSize(width: 0, height: -9),
            "尾道": CGSize(width: 0, height: 10),
            "広島": CGSize(width: 0, height: 10),
            "博多の屋台": CGSize(width: 6, height: 10)
        ],
        longitude: 129.95,
        latitude: 35.35,
        longitudeSpan: 6.0,
        latitudeSpan: 3.2,
        backdrop: "map_osakaHakata"
    )
}
