import Core
import Features
import Store
import Testing

@MainActor
struct CompanionPickerModelTests {
    @Test
    func startsWithShibaWhenNoCompanion() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        #expect(model.species == .shiba)
        #expect(model.coat == .black)
        #expect(model.name == "こむぎ")
    }

    @Test
    func resetsCoatAndNameWhenSpeciesChanges() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        model.select(.penguin)

        #expect(model.species == .penguin)
        #expect(model.coat == .gray)
        #expect(model.name == "ぺんた")
    }

    @Test
    func keepsNameWhenSpeciesChangesAfterRename() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        model.rename("もも")
        model.select(.tanuki)

        #expect(model.name == "もも")
        #expect(model.coat == .brown)
    }

    @Test
    func keepsLongNameButHasNoDraft() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        model.rename("あいうえおかきくけ")

        #expect(model.name == "あいうえおかきくけ")
        #expect(model.isNameTooLong)
        #expect(model.draft == nil)
    }

    @Test
    func acceptsNameAtLimit() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        model.rename(" あいうえおかきく ")

        #expect(!model.isNameTooLong)
        #expect(model.draft?.name == "あいうえおかきく")
    }

    @Test
    func hasNoDraftWhenNameIsEmpty() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        model.rename("")

        #expect(model.draft == nil)
        #expect(!model.save())
        #expect(model.preview?.name == "こむぎ")
    }

    @Test
    func savesDraftToDatabase() throws {
        let database = try AppDatabase.inMemory()
        let model = CompanionPickerModel(database: database)
        let expected = Companion(species: .penguin, coat: .king, name: "ぴぴ")

        model.select(.penguin)
        model.select(.king)
        model.rename("ぴぴ")

        #expect(model.save())
        #expect(try database.companion() == expected)
    }

    @Test
    func startsWithSavedCompanion() throws {
        let database = try AppDatabase.inMemory()
        let saved = try #require(Companion(species: .tanuki, coat: .white, name: "ふく"))
        try database.saveCompanion(saved)

        let model = CompanionPickerModel(database: database)

        #expect(model.draft == saved)
    }
}
