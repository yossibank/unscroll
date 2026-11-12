@testable import Core
import Testing

struct CompanionTests {
    @Test
    func makesCompanionWithValidValues() {
        let companion = Companion(species: .shiba, coat: .black, name: "こむぎ")

        #expect(companion?.species == .shiba)
        #expect(companion?.coat == .black)
        #expect(companion?.name == "こむぎ")
    }

    @Test
    func rejectsCoatOutsideSpecies() {
        let companion = Companion(species: .penguin, coat: .red, name: "ぺんた")

        #expect(companion == nil)
    }

    @Test
    func rejectsBlankName() {
        let empty = Companion(species: .shiba, coat: .black, name: "")
        let blank = Companion(species: .shiba, coat: .black, name: " \n　")

        #expect(empty == nil)
        #expect(blank == nil)
    }

    @Test
    func rejectsNameOverLimit() {
        let companion = Companion(species: .shiba, coat: .black, name: "あいうえおかきくけ")

        #expect(companion == nil)
    }

    @Test
    func acceptsNameAtLimit() {
        let companion = Companion(species: .shiba, coat: .black, name: "あいうえおかきく")

        #expect(companion?.name == "あいうえおかきく")
    }

    @Test
    func trimsSurroundingWhitespace() {
        let companion = Companion(species: .shiba, coat: .black, name: "  こむぎ\n")

        #expect(companion?.name == "こむぎ")
    }

    @Test
    func trimsBeforeCountingLimit() {
        let companion = Companion(species: .shiba, coat: .black, name: " あいうえおかきく ")

        #expect(companion?.name == "あいうえおかきく")
    }

    @Test
    func buildsArtName() {
        let companion = Companion(species: .shiba, coat: .black, name: "こむぎ")

        #expect(companion?.artName(.walkLeft) == "shiba_black_walk_left")
        #expect(companion?.artName(.walk) == "shiba_black_walk")
    }
}
