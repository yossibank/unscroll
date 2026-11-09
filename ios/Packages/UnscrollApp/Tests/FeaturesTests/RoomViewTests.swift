import Features
import Store
import Testing

@MainActor
struct RoomViewTests {
    @Test
    func makesBody() throws {
        let model = try RoomModel(database: AppDatabase.inMemory())

        _ = RoomView(model: model).body
    }
}
