import FeatureModels
import Features
import Store
import Testing

@MainActor
struct EventLogViewTests {
    @Test
    func makesBody() throws {
        let model = try SettingsModel(parts: .system(AppDatabase.inMemory()))

        _ = EventLogView(model: model).body
    }
}
