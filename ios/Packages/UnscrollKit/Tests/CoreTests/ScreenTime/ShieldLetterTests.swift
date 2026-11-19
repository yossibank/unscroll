import Core
import Testing

struct ShieldLetterTests {
    @Test
    func writesRemainingMinutes() {
        let letter = ShieldLetter(companionName: "ぽん", remainingMinutes: 23)

        #expect(letter.title == "ぽんより")
        #expect(letter.primaryButton == "旅に戻る")
        #expect(letter.body == "旅はあと 23 分\nスマホはお休みしててね。")
    }

    @Test
    func fallsBackWithoutCompanionAndMinutes() {
        let letter = ShieldLetter(companionName: nil, remainingMinutes: nil)

        #expect(letter.title == "旅先からの手紙")
        #expect(letter.primaryButton == "旅に戻る")
        #expect(letter.body == "旅の途中だよ\nスマホはお休みしててね。")
    }
}
