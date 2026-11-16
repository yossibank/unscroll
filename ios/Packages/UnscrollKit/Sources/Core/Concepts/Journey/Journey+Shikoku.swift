public extension Journey {
    static let shikoku = Journey(
        id: "shikoku",
        name: "四国一周",
        landmarks: [
            Landmark(name: "鳴門の渦潮", kilometer: 0, artKey: "naruto"),
            Landmark(name: "桂浜", kilometer: 200, artKey: "katsurahama", souvenir: "かつおのたたき"),
            Landmark(name: "四万十川", kilometer: 330, artKey: "shimanto", souvenir: "川えびの唐揚げ"),
            Landmark(name: "道後温泉", kilometer: 480, artKey: "dogo", souvenir: "坊っちゃん団子"),
            Landmark(name: "しまなみ海道", kilometer: 550, artKey: "shimanami", souvenir: "じゃこ天"),
            Landmark(name: "金刀比羅宮", kilometer: 640, artKey: "konpira", souvenir: "讃岐うどん")
        ]
    )
}
