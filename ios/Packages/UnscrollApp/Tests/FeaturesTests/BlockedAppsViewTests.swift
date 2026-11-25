import FeatureModels
import Features
import Store
import Testing

@MainActor
struct BlockedAppsViewTests {
    @Test
    func makesBody() throws {
        let model = try SettingsModel(parts: .system(AppDatabase.inMemory()))

        _ = BlockedAppsView(model: model).body
    }
}
