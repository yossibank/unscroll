public extension Journey {
    static let practice = Journey(
        id: "practice",
        name: "練習の旅",
        landmarks: [
            Landmark(
                name: "おるすの部屋",
                kilometer: 0,
                artKey: "orusueki"
            ),
            Landmark(
                name: "おるす駅",
                kilometer: 0,
                artKey: "orusueki",
                souvenir: "おるすまんじゅう",
                remark: "はじめての旅、おつかれさま！"
            )
        ]
    )

    static var practiceStation: Landmark? {
        practice.landmarks.last
    }
}
