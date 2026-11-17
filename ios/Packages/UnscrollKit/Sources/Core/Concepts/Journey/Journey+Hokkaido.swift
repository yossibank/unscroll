public extension Journey {
    static let hokkaido = Journey(
        id: "hokkaido",
        name: "函館 → 旭川",
        landmarks: [
            Landmark(
                name: "函館",
                kilometer: 0,
                artKey: "hakodate"
            ),
            Landmark(
                name: "大沼",
                kilometer: 30,
                artKey: "onuma",
                souvenir: "大沼だんご",
                remark: "駒ヶ岳が見えてきた"
            ),
            Landmark(
                name: "洞爺湖",
                kilometer: 160,
                artKey: "toyako",
                souvenir: "じゃがバター",
                remark: "湖のにおいがしてきた"
            ),
            Landmark(
                name: "小樽",
                kilometer: 290,
                artKey: "otaru",
                souvenir: "小樽の寿司",
                remark: "運河まで、もうすこし"
            ),
            Landmark(
                name: "札幌",
                kilometer: 330,
                artKey: "sapporo",
                souvenir: "味噌ラーメン",
                remark: "大きな町が近いよ"
            ),
            Landmark(
                name: "富良野",
                kilometer: 440,
                artKey: "furano",
                souvenir: "メロン",
                remark: "ラベンダーのかおりがする"
            ),
            Landmark(
                name: "旭川",
                kilometer: 500,
                artKey: "asahikawa",
                souvenir: "旭川ラーメン",
                remark: "雪のにおいがする"
            )
        ]
    )
}
