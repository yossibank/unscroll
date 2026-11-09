import Features
import Testing

@MainActor
struct JourneyMapViewTests {
    @Test
    func makesBody() {
        _ = JourneyMapView().body
    }
}
