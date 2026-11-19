import Features
import Store
import Testing

@MainActor
struct RoomViewTests {
    @Test
    func makesBody() throws {
        let database = try AppDatabase.inMemory()
        let model = RoomModel(database: database)
        let settings = SettingsModel(database: database)

        _ = RoomView(model: model, settings: settings).body
    }
}
