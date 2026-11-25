import Core
import FeatureModels
import Store
import Testing

@MainActor
struct CompanionPickerModelTests {
    @Test
    func startsWithPenguinWhenNoCompanion() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        #expect(model.species == .penguin)
        #expect(model.coat == .gray)
        #expect(model.name == "ぺんた")
    }

    @Test
    func resetsCoatAndNameWhenSpeciesChanges() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        model.select(.penguin)

        #expect(model.species == .penguin)
        #expect(model.coat == .gray)
        #expect(model.name == "ぺんた")
    }

    @Test
    func keepsNameWhenSpeciesChangesAfterRename() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        model.rename("もも")
        model.select(.tanuki)

        #expect(model.name == "もも")
        #expect(model.coat == .brown)
    }

    @Test
    func keepsLongNameButHasNoDraft() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        model.rename("あいうえおかきくけ")

        #expect(model.name == "あいうえおかきくけ")
        #expect(model.isNameTooLong)
        #expect(model.draft == nil)
    }

    @Test
    func acceptsNameAtLimit() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        model.rename(" あいうえおかきく ")

        #expect(!model.isNameTooLong)
        #expect(model.draft?.name == "あいうえおかきく")
    }

    @Test
    func hasNoDraftWhenNameIsEmpty() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        model.rename("")

        #expect(model.draft == nil)
        #expect(!model.save())
        #expect(model.preview?.name == "ぺんた")
    }

    @Test
    func savesDraftToDatabase() throws {
        let database = try AppDatabase.inMemory()
        let model = CompanionPickerModel(parts: .system(database))
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

        let model = CompanionPickerModel(parts: .system(database))

        #expect(model.draft == saved)
    }

    @Test
    func canSaveOnlyAfterChangingSavedCompanion() throws {
        let database = try AppDatabase.inMemory()
        let saved = try #require(Companion(species: .tanuki, coat: .white, name: "ふく"))
        try database.saveCompanion(saved)

        let model = CompanionPickerModel(parts: .system(database))

        #expect(!model.isChanged)
        #expect(!model.canSave)

        model.select(.gray)

        #expect(model.isChanged)
        #expect(model.canSave)

        #expect(model.save())
        #expect(!model.isChanged)
    }

    @Test
    func canSaveWhenNoCompanionIsSaved() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        #expect(model.isChanged)
        #expect(model.canSave)
    }
}
