public extension Journey {
    static let osakaHakata = Journey(
        id: "osakaHakata",
        name: "大阪 → 博多 食べ歩き",
        landmarks: [
            Landmark(
                name: "道頓堀",
                kilometer: 0,
                artKey: "dotonbori"
            ),
            Landmark(
                name: "神戸の南京町",
                kilometer: 35,
                artKey: "nankinmachi",
                souvenir: "豚まん",
                remark: "豚まんのいいにおい！"
            ),
            Landmark(
                name: "明石",
                kilometer: 60,
                artKey: "akashi",
                souvenir: "明石焼き",
                remark: "明石焼き、ふーふーしよう"
            ),
            Landmark(
                name: "岡山",
                kilometer: 160,
                artKey: "okayama",
                souvenir: "きびだんご",
                remark: "きびだんご、もらえるかな"
            ),
            Landmark(
                name: "尾道",
                kilometer: 230,
                artKey: "onomichi",
                souvenir: "尾道ラーメン",
                remark: "坂道とねこの町だって"
            ),
            Landmark(
                name: "広島",
                kilometer: 310,
                artKey: "hiroshima",
                souvenir: "お好み焼き",
                remark: "お好み焼き、たのしみ！"
            ),
            Landmark(
                name: "博多の屋台",
                kilometer: 570,
                artKey: "hakata",
                souvenir: "博多ラーメン",
                remark: "屋台のあかりが見えてきた"
            )
        ]
    )
}
