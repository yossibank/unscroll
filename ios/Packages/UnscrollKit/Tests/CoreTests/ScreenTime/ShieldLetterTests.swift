import Core
import Testing

struct ShieldLetterTests {
    @Test
    func writesNextLandmarkDistanceAndMinutes() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: 78,
            remainingMinutes: 23
        )

        #expect(letter.title == "ぽんから手紙が届いたよ")
        #expect(letter.body == "まだ帰らないよ。芦ノ湖まで、あと 12 km。旅はあと 23 分。いっしょに行こう。")
    }

    @Test
    func leavesOutMinutesWithoutActiveTrip() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: 78,
            remainingMinutes: nil
        )
        #expect(letter.body == "まだ帰らないよ。芦ノ湖まで、あと 12 km。いっしょに行こう。")
    }

    @Test
    func leavesOutDistanceAfterLastLandmark() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: 500,
            remainingMinutes: nil
        )
        #expect(letter.body == "まだ帰らないよ。いっしょに行こう。")
    }

    @Test
    func leavesOutDistanceWithoutProgress() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: nil,
            remainingMinutes: 5
        )
        #expect(letter.body == "まだ帰らないよ。旅はあと 5 分。いっしょに行こう。")
    }

    @Test
    func groupsDistanceDigitsOverOneThousandKilometers() {
        let journey = Journey(
            id: "long",
            name: "長い旅",
            landmarks: [
                Landmark(name: "出発", kilometer: 0, artKey: "start"),
                Landmark(name: "遠い町", kilometer: 1250, artKey: "far")
            ]
        )
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: journey,
            kilometers: 0,
            remainingMinutes: nil
        )
        let distance = 1250.formatted()

        #expect(letter.body == "まだ帰らないよ。遠い町まで、あと \(distance) km。いっしょに行こう。")
    }

    @Test
    func callsCompanionByRoleWithoutName() {
        let letter = ShieldLetter(
            companionName: nil,
            journey: .tokyoToKyoto,
            kilometers: 0,
            remainingMinutes: nil
        )
        #expect(letter.title == "相棒から手紙が届いたよ")
    }
}
