public extension Journey {
    static let hokkaido = Journey(
        id: "hokkaido",
        name: "函館 → 旭川",
        landmarks: [
            Landmark(name: "函館", kilometer: 0, artKey: "hakodate"),
            Landmark(name: "大沼", kilometer: 30, artKey: "onuma", souvenir: "大沼だんご"),
            Landmark(name: "洞爺湖", kilometer: 160, artKey: "toyako", souvenir: "じゃがバター"),
            Landmark(name: "小樽", kilometer: 290, artKey: "otaru", souvenir: "小樽の寿司"),
            Landmark(name: "札幌", kilometer: 330, artKey: "sapporo", souvenir: "味噌ラーメン"),
            Landmark(name: "富良野", kilometer: 440, artKey: "furano", souvenir: "メロン"),
            Landmark(name: "旭川", kilometer: 500, artKey: "asahikawa", souvenir: "旭川ラーメン")
        ]
    )
}
