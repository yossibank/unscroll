public extension Journey {
    static let okinawa = Journey(
        id: "okinawa",
        name: "沖縄めぐり",
        landmarks: [
            Landmark(name: "那覇空港", kilometer: 0, artKey: "nahakuko"),
            Landmark(name: "首里城", kilometer: 10, artKey: "shurijo", souvenir: "ちんすこう"),
            Landmark(name: "斎場御嶽", kilometer: 35, artKey: "sefautaki", souvenir: "サーターアンダギー"),
            Landmark(name: "万座毛", kilometer: 90, artKey: "manzamo", souvenir: "紅いもタルト"),
            Landmark(name: "備瀬のフクギ並木", kilometer: 120, artKey: "bise", souvenir: "沖縄そば"),
            Landmark(name: "古宇利島", kilometer: 140, artKey: "kourijima", souvenir: "海ぶどう")
        ]
    )
}
