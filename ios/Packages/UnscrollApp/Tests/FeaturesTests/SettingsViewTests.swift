import Features
import Store
import Testing

@MainActor
struct SettingsViewTests {
    @Test
    func makesBody() throws {
        let model = try SettingsModel(database: AppDatabase.inMemory())

        _ = SettingsView(model: model).body
    }
}
