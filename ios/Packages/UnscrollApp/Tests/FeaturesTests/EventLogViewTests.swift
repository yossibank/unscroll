import Features
import Store
import Testing

@MainActor
struct EventLogViewTests {
    @Test
    func makesBody() throws {
        let model = try SettingsModel(database: AppDatabase.inMemory())

        _ = EventLogView(model: model).body
    }
}
