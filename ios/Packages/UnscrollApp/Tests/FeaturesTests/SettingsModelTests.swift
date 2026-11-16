import FamilyControls
@testable import Features
import Store
import Testing

@MainActor
struct SettingsModelTests {
    @Test
    func showsUnselectedWhenNoAppsAreChosen() throws {
        let model = try SettingsModel(database: AppDatabase.inMemory())

        model.selection = FamilyActivitySelection()

        #expect(!model.hasSelection)
        #expect(!model.isReady)
        #expect(model.selectionSummary == "未選択")
    }
}
