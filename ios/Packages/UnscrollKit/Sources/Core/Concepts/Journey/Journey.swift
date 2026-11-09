public struct Journey: Hashable, Sendable {
    public let name: String
    public let landmarks: [Landmark]

    public init(
        name: String,
        landmarks: [Landmark]
    ) {
        self.name = name
        self.landmarks = landmarks
    }
}

public extension Journey {
    static let tokyoToKyoto = Journey(
        name: "東京 → 京都",
        landmarks: [
            Landmark(name: "日本橋", kilometer: 0),
            Landmark(name: "芦ノ湖", kilometer: 90),
            Landmark(name: "三保の松原", kilometer: 170),
            Landmark(name: "浜名湖", kilometer: 260),
            Landmark(name: "名古屋城", kilometer: 350),
            Landmark(name: "琵琶湖", kilometer: 450),
            Landmark(name: "清水寺", kilometer: 500)
        ]
    )

    var totalKilometers: Int {
        landmarks.last?.kilometer ?? 0
    }

    func nextLandmark(after kilometers: Int) -> Landmark? {
        landmarks.first { $0.kilometer > kilometers }
    }

    func landmarkReached(
        from start: Int,
        to end: Int
    ) -> Landmark? {
        landmarks.last { $0.kilometer > start && $0.kilometer <= end }
    }
}
