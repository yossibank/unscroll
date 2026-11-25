import FeatureModels
import Features
import Store
import Testing

@MainActor
struct CompanionPickerViewTests {
    @Test
    func makesBody() throws {
        let model = try CompanionPickerModel(parts: .system(AppDatabase.inMemory()))

        _ = CompanionPickerView(model: model).body
    }
}
