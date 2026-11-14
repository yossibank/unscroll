import Core
import Testing

struct ShieldLetterTests {
    @Test
    func writesNextLandmarkAndDistance() {
        let letter = ShieldLetter(companionName: "ぽん", journey: .tokyoToKyoto, kilometers: 78)

        #expect(letter.title == "ぽんから手紙が届いたよ")
        #expect(letter.body == "まだ帰らないよ。芦ノ湖まで、あと 12 km。いっしょに行こう。")
    }

    @Test
    func leavesOutDistanceAfterLastLandmark() {
        let letter = ShieldLetter(companionName: "ぽん", journey: .tokyoToKyoto, kilometers: 500)
        #expect(letter.body == "まだ帰らないよ。いっしょに行こう。")
    }

    @Test
    func leavesOutDistanceWithoutProgress() {
        let letter = ShieldLetter(companionName: "ぽん", journey: .tokyoToKyoto, kilometers: nil)
        #expect(letter.body == "まだ帰らないよ。いっしょに行こう。")
    }

    @Test
    func callsCompanionByRoleWithoutName() {
        let letter = ShieldLetter(companionName: nil, journey: .tokyoToKyoto, kilometers: 0)
        #expect(letter.title == "相棒から手紙が届いたよ")
    }
}
