import Features
import Store
import Testing

@MainActor
struct FocusPrototypeViewTests {
    @Test
    func makesBody() throws {
        let model = try FocusPrototypeModel(database: AppDatabase.inMemory())

        _ = FocusPrototypeView(model: model).body
    }
}
