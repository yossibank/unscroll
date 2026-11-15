public extension Landmark {
    var artName: String {
        "landmark_\(artKey)"
    }

    var souvenirArtName: String? {
        souvenir == nil ? nil : "souvenir_\(artKey)"
    }
}

private extension Landmark {
    var artKey: String {
        switch name {
        case "日本橋":
            "nihonbashi"
        case "芦ノ湖":
            "ashinoko"
        case "三保の松原":
            "miho"
        case "浜名湖":
            "hamanako"
        case "名古屋城":
            "nagoyajo"
        case "琵琶湖":
            "biwako"
        case "清水寺":
            "kiyomizu"
        default:
            name
        }
    }
}
