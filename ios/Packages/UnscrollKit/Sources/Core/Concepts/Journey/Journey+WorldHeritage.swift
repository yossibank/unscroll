public extension Journey {
    static let worldHeritage = Journey(
        id: "worldHeritage",
        name: "日本の世界遺産めぐり",
        landmarks: [
            Landmark(
                name: "日光の社寺",
                kilometer: 0,
                artKey: "nikko"
            ),
            Landmark(
                name: "富岡製糸場",
                kilometer: 160,
                artKey: "tomioka",
                souvenir: "おっきりこみ",
                remark: "レンガの建物が見えてきた！"
            ),
            Landmark(
                name: "富士山",
                kilometer: 320,
                artKey: "fujisan",
                souvenir: "ほうとう",
                remark: "富士山がだんだん大きく！"
            ),
            Landmark(
                name: "白川郷",
                kilometer: 620,
                artKey: "shirakawago",
                souvenir: "五平餅",
                remark: "とんがり屋根の村へ"
            ),
            Landmark(
                name: "古都奈良",
                kilometer: 870,
                artKey: "nara",
                souvenir: "柿の葉寿司",
                remark: "鹿さんに会えるかな"
            ),
            Landmark(
                name: "姫路城",
                kilometer: 990,
                artKey: "himejijo",
                souvenir: "姫路おでん",
                remark: "白いお城がきれい！"
            ),
            Landmark(
                name: "厳島神社",
                kilometer: 1250,
                artKey: "itsukushima",
                souvenir: "もみじ饅頭",
                remark: "海に立つ鳥居、もうすぐ！"
            )
        ]
    )
}
