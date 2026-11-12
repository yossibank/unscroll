import Features
import Store
import Testing

@MainActor
struct CompanionPickerViewTests {
    @Test
    func makesBody() throws {
        let model = try CompanionPickerModel(database: AppDatabase.inMemory())

        _ = CompanionPickerView(model: model, isFirstTime: true).body
    }
}
