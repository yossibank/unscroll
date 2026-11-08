@testable import Core
import Testing

struct JourneyTests {
    private let journey = Journey.tokyoToKyoto

    @Test
    func findsNextLandmark() {
        #expect(journey.nextLandmark(after: 0)?.name == "芦ノ湖")
        #expect(journey.nextLandmark(after: 89)?.name == "芦ノ湖")
        #expect(journey.nextLandmark(after: 90)?.name == "三保の松原")
        #expect(journey.nextLandmark(after: 500) == nil)
        #expect(journey.nextLandmark(after: 600) == nil)
    }

    @Test
    func findsLandmarkReached() {
        #expect(journey.landmarkReached(from: 10, to: 80) == nil)
        #expect(journey.landmarkReached(from: 65, to: 90)?.name == "芦ノ湖")
        #expect(journey.landmarkReached(from: 90, to: 100) == nil)
        #expect(journey.landmarkReached(from: 80, to: 180)?.name == "三保の松原")
    }

    @Test
    func totalsKilometers() {
        #expect(journey.totalKilometers == 500)
        #expect(Journey(name: "空", landmarks: []).totalKilometers == 0)
    }
}
