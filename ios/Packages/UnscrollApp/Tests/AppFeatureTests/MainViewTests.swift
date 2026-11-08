import AppFeature
import Store
import Testing

@MainActor
struct MainViewTests {
    @Test
    func makesBody() throws {
        let database = try AppDatabase.inMemory()

        _ = MainView(database: database).body
    }
}
