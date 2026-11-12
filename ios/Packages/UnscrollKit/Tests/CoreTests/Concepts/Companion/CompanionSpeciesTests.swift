@testable import Core
import Testing

struct CompanionSpeciesTests {
    @Test
    func hasFourCoatsForEverySpecies() {
        for species in Companion.Species.allCases {
            #expect(species.coats.count == 4)
        }
    }

    @Test
    func labelsEveryCoat() {
        for species in Companion.Species.allCases {
            for coat in species.coats {
                #expect(!species.label(of: coat).isEmpty)
            }
        }
    }

    @Test
    func makesCompanionWithDefaultNameAndFirstCoat() {
        for species in Companion.Species.allCases {
            let companion = Companion(
                species: species,
                coat: species.coats[0],
                name: species.defaultName
            )

            #expect(companion != nil)
        }
    }
}
