import CoreGraphics

enum JourneyMapGeometry {
    static let aspectRatio: CGFloat = 228 / 150

    static let land: [CGPoint] = [
        CGPoint(x: 135.3, y: 36.6), CGPoint(x: 140.5, y: 36.6), CGPoint(x: 140.5, y: 35.25),
        CGPoint(x: 140.1, y: 35.0), CGPoint(x: 139.85, y: 34.92), CGPoint(x: 139.75, y: 35.15),
        CGPoint(x: 139.95, y: 35.45), CGPoint(x: 139.8, y: 35.64), CGPoint(x: 139.68, y: 35.5),
        CGPoint(x: 139.65, y: 35.3), CGPoint(x: 139.7, y: 35.15), CGPoint(x: 139.55, y: 35.27),
        CGPoint(x: 139.3, y: 35.3), CGPoint(x: 139.15, y: 35.15), CGPoint(x: 139.1, y: 34.95),
        CGPoint(x: 138.95, y: 34.65), CGPoint(x: 138.85, y: 34.6), CGPoint(x: 138.75, y: 34.75),
        CGPoint(x: 138.85, y: 35.05), CGPoint(x: 138.6, y: 35.1), CGPoint(x: 138.5, y: 34.95),
        CGPoint(x: 138.25, y: 34.6), CGPoint(x: 137.7, y: 34.65), CGPoint(x: 137.3, y: 34.6),
        CGPoint(x: 137.0, y: 34.6), CGPoint(x: 137.25, y: 34.75), CGPoint(x: 137.05, y: 34.85),
        CGPoint(x: 136.95, y: 34.7), CGPoint(x: 136.85, y: 34.9), CGPoint(x: 136.85, y: 35.05),
        CGPoint(x: 136.62, y: 34.97), CGPoint(x: 136.52, y: 34.72), CGPoint(x: 136.72, y: 34.5),
        CGPoint(x: 136.85, y: 34.45), CGPoint(x: 136.8, y: 34.2), CGPoint(x: 135.3, y: 34.2)
    ]

    static let biwa: [CGPoint] = [
        CGPoint(x: 135.92, y: 35.0), CGPoint(x: 135.95, y: 35.2), CGPoint(x: 136.05, y: 35.42),
        CGPoint(x: 136.2, y: 35.52), CGPoint(x: 136.27, y: 35.42), CGPoint(x: 136.1, y: 35.2),
        CGPoint(x: 136.0, y: 35.02)
    ]

    static let mountains: [CGPoint] = [
        CGPoint(x: 136.4, y: 35.9), CGPoint(x: 137.4, y: 35.9), CGPoint(x: 138.3, y: 35.8),
        CGPoint(x: 139.2, y: 35.95), CGPoint(x: 137.8, y: 35.4), CGPoint(x: 136.2, y: 35.7)
    ]

    static let spots: [String: CGPoint] = [
        "日本橋": CGPoint(x: 139.77, y: 35.68),
        "芦ノ湖": CGPoint(x: 139.02, y: 35.2),
        "三保の松原": CGPoint(x: 138.52, y: 35.0),
        "浜名湖": CGPoint(x: 137.6, y: 34.75),
        "名古屋城": CGPoint(x: 136.9, y: 35.18),
        "琵琶湖": CGPoint(x: 135.98, y: 35.08),
        "清水寺": CGPoint(x: 135.78, y: 35.0)
    ]

    static let fuji = CGPoint(x: 138.73, y: 35.36)

    static let labelOffsets: [String: CGSize] = [
        "日本橋": CGSize(width: 0, height: -8),
        "浜名湖": CGSize(width: 0, height: 13),
        "名古屋城": CGSize(width: 4, height: -9),
        "清水寺": CGSize(width: -2, height: 14)
    ]

    static func project(
        longitude: Double,
        latitude: Double,
        in size: CGSize
    ) -> CGPoint {
        CGPoint(
            x: (longitude - 135.3) / 5.1 * size.width,
            y: (36.45 - latitude) / 2.2 * size.height
        )
    }

    static func project(
        _ point: CGPoint,
        in size: CGSize
    ) -> CGPoint {
        project(longitude: point.x, latitude: point.y, in: size)
    }
}
