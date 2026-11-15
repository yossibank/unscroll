public extension Landmark {
    var souvenir: String? {
        switch name {
        case "芦ノ湖":
            "大涌谷の黒たまご"
        case "三保の松原":
            "静岡おでん"
        case "浜名湖":
            "うな重"
        case "名古屋城":
            "天むす"
        case "琵琶湖":
            "鮎の塩焼き"
        case "清水寺":
            "生八ッ橋"
        default:
            nil
        }
    }
}
