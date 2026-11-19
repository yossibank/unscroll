public extension Journey {
    static let tokyoSightseeing = Journey(
        id: "tokyoSightseeing",
        name: "東京の名所めぐり",
        landmarks: [
            Landmark(
                name: "東京駅",
                kilometer: 0,
                artKey: "tokyoeki"
            ),
            Landmark(
                name: "皇居",
                kilometer: 3,
                artKey: "kokyo",
                souvenir: "もなか",
                remark: "お堀の緑がきれいだね"
            ),
            Landmark(
                name: "浅草",
                kilometer: 12,
                artKey: "asakusa",
                souvenir: "雷おこし",
                remark: "大きなちょうちんだ！"
            ),
            Landmark(
                name: "東京スカイツリー",
                kilometer: 15,
                artKey: "skytree",
                souvenir: "人形焼き",
                remark: "見上げると首がいたいね"
            ),
            Landmark(
                name: "お台場",
                kilometer: 32,
                artKey: "odaiba",
                souvenir: "もんじゃ焼き",
                remark: "海の風が気持ちいい"
            ),
            Landmark(
                name: "東京タワー",
                kilometer: 48,
                artKey: "tokyotower",
                souvenir: "どら焼き",
                remark: "赤いタワーにとうちゃく！"
            )
        ]
    )
}
