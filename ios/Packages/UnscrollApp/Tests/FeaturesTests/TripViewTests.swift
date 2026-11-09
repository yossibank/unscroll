import Features
import Store
import Testing

@MainActor
struct TripViewTests {
    @Test
    func makesBody() throws {
        let model = try RoomModel(database: AppDatabase.inMemory())

        _ = TripView(model: model).body
    }
}
