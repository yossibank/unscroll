public extension Landmark {
    var souvenir: String? {
        switch name {
        case "芦ノ湖":
            "寄木細工のコースター"
        case "三保の松原":
            "静岡のお茶"
        case "浜名湖":
            "浜名湖ののり"
        case "名古屋城":
            "しゃちほこの置物"
        case "琵琶湖":
            "信楽焼のたぬき"
        case "清水寺":
            "清水焼の湯のみ"
        default:
            nil
        }
    }
}
