import FeatureModels
import Features
import Store
import Testing

@MainActor
struct RoomViewTests {
    @Test
    func makesBody() throws {
        let database = try AppDatabase.inMemory()
        let model = RoomModel(parts: .system(database))
        let settings = SettingsModel(parts: .system(database))

        _ = RoomView(model: model, settings: settings).body
    }
}
