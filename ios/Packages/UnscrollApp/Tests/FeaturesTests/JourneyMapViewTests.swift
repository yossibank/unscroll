@testable import Features
import Store
import Testing

@MainActor
struct JourneyMapViewTests {
    @Test
    func makesBody() throws {
        let model = try JourneyMapModel(database: AppDatabase.inMemory())

        _ = JourneyMapView(model: model).body
    }

    @Test
    func makesCanvasBody() throws {
        let model = try JourneyMapModel(database: AppDatabase.inMemory())

        _ = JourneyMapCanvas(journey: model.journey, kilometers: model.kilometers).body
    }
}
