public extension Journey {
    static let tohokuShinkansen = Journey(
        id: "tohokuShinkansen",
        name: "東北新幹線 駅弁の旅",
        landmarks: [
            Landmark(
                name: "東京駅",
                kilometer: 0,
                artKey: "tokyoeki"
            ),
            Landmark(
                name: "宇都宮駅",
                kilometer: 110,
                artKey: "utsunomiya",
                souvenir: "餃子弁当",
                remark: "餃子、たのしみだな"
            ),
            Landmark(
                name: "仙台駅",
                kilometer: 352,
                artKey: "sendai",
                souvenir: "牛たん弁当",
                remark: "牛たん弁当、待っててね"
            ),
            Landmark(
                name: "盛岡駅",
                kilometer: 535,
                artKey: "morioka",
                souvenir: "わんこそば",
                remark: "わんこそば、何杯いけるかな"
            ),
            Landmark(
                name: "八戸駅",
                kilometer: 632,
                artKey: "hachinohe",
                souvenir: "いちご煮",
                remark: "海の幸がまってる！"
            ),
            Landmark(
                name: "新青森駅",
                kilometer: 714,
                artKey: "shinaomori",
                souvenir: "ほたて弁当",
                remark: "りんごの木がふえてきた"
            )
        ]
    )
}
