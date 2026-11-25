import AppFeature
import FeatureModels
import Store
import Testing

@MainActor
struct MainViewTests {
    @Test
    func makesBody() throws {
        let database = try AppDatabase.inMemory()

        _ = MainView(parts: ScreenParts(database: database, clock: .system)).body
    }
}
