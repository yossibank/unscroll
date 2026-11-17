public extension Journey {
    static let okinawa = Journey(
        id: "okinawa",
        name: "沖縄めぐり",
        landmarks: [
            Landmark(
                name: "那覇空港",
                kilometer: 0,
                artKey: "nahakuko"
            ),
            Landmark(
                name: "首里城",
                kilometer: 10,
                artKey: "shurijo",
                souvenir: "ちんすこう",
                remark: "赤いお城がたのしみ！"
            ),
            Landmark(
                name: "斎場御嶽",
                kilometer: 35,
                artKey: "sefautaki",
                souvenir: "サーターアンダギー",
                remark: "森の中、しずかな道だね"
            ),
            Landmark(
                name: "万座毛",
                kilometer: 90,
                artKey: "manzamo",
                souvenir: "紅いもタルト",
                remark: "海の色がどんどん青くなる"
            ),
            Landmark(
                name: "備瀬のフクギ並木",
                kilometer: 120,
                artKey: "bise",
                souvenir: "沖縄そば",
                remark: "木かげの道、すずしいね"
            ),
            Landmark(
                name: "古宇利島",
                kilometer: 140,
                artKey: "kourijima",
                souvenir: "海ぶどう",
                remark: "長い橋をわたるよ！"
            )
        ]
    )
}
