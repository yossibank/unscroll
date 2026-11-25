import FeatureModels
import Features
import Store
import Testing

@MainActor
struct TripViewTests {
    @Test
    func makesBody() throws {
        let model = try RoomModel(parts: .system(AppDatabase.inMemory()))

        _ = TripView(model: model).body
    }
}
