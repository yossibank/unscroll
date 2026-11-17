import CoreGraphics

extension JourneyMapGeometry {
    static let okinawa = JourneyMapGeometry(
        spots: [
            "那覇空港": CGPoint(x: 127.646, y: 26.196),
            "首里城": CGPoint(x: 127.719, y: 26.217),
            "斎場御嶽": CGPoint(x: 127.827, y: 26.174),
            "万座毛": CGPoint(x: 127.855, y: 26.505),
            "備瀬のフクギ並木": CGPoint(x: 127.879, y: 26.708),
            "古宇利島": CGPoint(x: 128.025, y: 26.703)
        ],
        labelOffsets: [
            "那覇空港": CGSize(width: -8, height: 10),
            "首里城": CGSize(width: 0, height: -9),
            "斎場御嶽": CGSize(width: 6, height: 10),
            "万座毛": CGSize(width: -16, height: -6),
            "備瀬のフクギ並木": CGSize(width: -30, height: 10),
            "古宇利島": CGSize(width: 4, height: 10)
        ],
        longitude: 127.35,
        latitude: 26.78,
        longitudeSpan: 1.157,
        latitudeSpan: 0.68,
        backdrop: "map_okinawa"
    )
}
