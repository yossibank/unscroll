import CoreGraphics

extension JourneyMapGeometry {
    static let worldHeritage = JourneyMapGeometry(
        spots: [
            "日光の社寺": CGPoint(x: 139.6, y: 36.75),
            "富岡製糸場": CGPoint(x: 138.89, y: 36.25),
            "富士山": CGPoint(x: 138.73, y: 35.36),
            "白川郷": CGPoint(x: 136.9, y: 36.26),
            "古都奈良": CGPoint(x: 135.83, y: 34.69),
            "姫路城": CGPoint(x: 134.69, y: 34.84),
            "厳島神社": CGPoint(x: 132.32, y: 34.3)
        ],
        labelOffsets: [
            "日光の社寺": CGSize(width: 0, height: -9),
            "富岡製糸場": CGSize(width: 0, height: 10),
            "富士山": CGSize(width: 0, height: 10),
            "白川郷": CGSize(width: 0, height: -9),
            "古都奈良": CGSize(width: 0, height: 10),
            "姫路城": CGSize(width: 0, height: -9),
            "厳島神社": CGSize(width: 14, height: 10)
        ],
        longitude: 131.6,
        latitude: 37.7,
        longitudeSpan: 9.4,
        latitudeSpan: 4.4,
        backdrop: "map_worldHeritage"
    )
}
