public extension Journey {
    static let tokyoToKyoto = Journey(
        id: "tokaido",
        name: "東京 → 京都",
        landmarks: [
            Landmark(name: "日本橋", kilometer: 0, artKey: "nihonbashi"),
            Landmark(name: "芦ノ湖", kilometer: 90, artKey: "ashinoko", souvenir: "大涌谷の黒たまご"),
            Landmark(name: "三保の松原", kilometer: 170, artKey: "miho", souvenir: "静岡おでん"),
            Landmark(name: "浜名湖", kilometer: 260, artKey: "hamanako", souvenir: "うな重"),
            Landmark(name: "名古屋城", kilometer: 350, artKey: "nagoyajo", souvenir: "天むす"),
            Landmark(name: "琵琶湖", kilometer: 450, artKey: "biwako", souvenir: "鮎の塩焼き"),
            Landmark(name: "清水寺", kilometer: 500, artKey: "kiyomizu", souvenir: "生八ッ橋")
        ]
    )
}
