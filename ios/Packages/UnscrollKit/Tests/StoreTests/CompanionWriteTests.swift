import Core
import GRDB
@testable import Store
import Testing

struct CompanionWriteTests {
    @Test
    func returnsNilWhenEmpty() throws {
        let database = try AppDatabase.inMemory()

        #expect(try database.companion() == nil)
    }

    @Test
    func readsAfterSaving() throws {
        let database = try AppDatabase.inMemory()
        let companion = try #require(Companion(species: .tanuki, coat: .dark, name: "ぽん"))

        try database.saveCompanion(companion)

        #expect(try database.companion() == companion)
    }

    @Test
    func overwritesOnSecondSave() throws {
        let database = try AppDatabase.inMemory()
        let first = try #require(Companion(species: .tanuki, coat: .dark, name: "ぽん"))
        let second = try #require(Companion(species: .penguin, coat: .king, name: "ぺんた"))

        try database.saveCompanion(first)
        try database.saveCompanion(second)
        let count = try database.writer.read { try Companion.fetchCount($0) }

        #expect(try database.companion() == second)
        #expect(count == 1)
    }
}
