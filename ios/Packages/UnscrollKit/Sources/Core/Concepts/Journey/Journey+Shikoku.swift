public extension Journey {
    static let shikoku = Journey(
        id: "shikoku",
        name: "四国一周",
        landmarks: [
            Landmark(
                name: "鳴門の渦潮",
                kilometer: 0,
                artKey: "naruto"
            ),
            Landmark(
                name: "桂浜",
                kilometer: 200,
                artKey: "katsurahama",
                souvenir: "かつおのたたき",
                remark: "太平洋が見えてきた！"
            ),
            Landmark(
                name: "四万十川",
                kilometer: 330,
                artKey: "shimanto",
                souvenir: "川えびの唐揚げ",
                remark: "川の音が聞こえる"
            ),
            Landmark(
                name: "道後温泉",
                kilometer: 480,
                artKey: "dogo",
                souvenir: "坊っちゃん団子",
                remark: "温泉でひと休みしたい"
            ),
            Landmark(
                name: "しまなみ海道",
                kilometer: 550,
                artKey: "shimanami",
                souvenir: "じゃこ天",
                remark: "島から島へ、橋をわたるよ"
            ),
            Landmark(
                name: "金刀比羅宮",
                kilometer: 640,
                artKey: "konpira",
                souvenir: "讃岐うどん",
                remark: "石段、何段あるんだろう"
            )
        ]
    )
}
