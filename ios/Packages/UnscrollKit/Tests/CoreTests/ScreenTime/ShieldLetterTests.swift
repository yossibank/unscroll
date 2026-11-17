import Core
import Testing

struct ShieldLetterTests {
    @Test
    func writesPlaceNextLandmarkAndMinutes() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: 78,
            remainingMinutes: 23
        )
        let here = Journey.tokyoToKyoto.landmarks.last { $0.kilometer <= 78 }?.name ?? ""

        #expect(letter.title == "ぽんより")
        #expect(letter.primaryButton == "ぽんの旅に戻る")
        #expect(letter.body.hasPrefix("いま\(here)の近くを歩いてるよ。\n"))
        #expect(letter.body.contains("あと 12 km で芦ノ湖に着くんだ。"))
        #expect(letter.body.hasSuffix("旅はあと 23 分。スマホはお休みしててね。"))
    }

    @Test
    func leavesOutNextLandmarkAfterLastLandmark() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: 100_000,
            remainingMinutes: 5
        )

        #expect(!letter.body.contains("に着くんだ"))
        #expect(letter.body.hasSuffix("旅はあと 5 分。スマホはお休みしててね。"))
    }

    @Test
    func leavesOutPlacesWithoutProgress() {
        let letter = ShieldLetter(
            companionName: "ぽん",
            journey: .tokyoToKyoto,
            kilometers: nil,
            remainingMinutes: 5
        )
        #expect(letter.body == "旅はあと 5 分。スマホはお休みしててね。")
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

        #expect(letter.body == "いま出発の近くを歩いてるよ。\nあと \(distance) km で遠い町に着くんだ。")
    }

    @Test
    func fallsBackWithoutCompanion() {
        let letter = ShieldLetter(
            companionName: nil,
            journey: .tokyoToKyoto,
            kilometers: nil,
            remainingMinutes: nil
        )

        #expect(letter.title == "旅先からの手紙")
        #expect(letter.primaryButton == "旅に戻る")
        #expect(letter.body == "旅の途中だよ。スマホはお休みしててね。")
    }
}
