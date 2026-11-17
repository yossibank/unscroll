import Core
import Testing

struct JourneyCatalogTests {
    @Test
    func holdsSevenJourneysWithDistinctIDs() {
        let ids = Journey.all.map(\.id)

        #expect(ids.count == 7)
        #expect(Set(ids).count == ids.count)
    }

    @Test
    func keepsNamesAndArtKeysDistinctAcrossJourneys() {
        let landmarks = Journey.all.flatMap(\.landmarks)

        #expect(Set(landmarks.map(\.name)).count == landmarks.count)
        #expect(Set(landmarks.map(\.artKey)).count == landmarks.count)
    }

    @Test
    func givesEveryLandmarkExceptTheStartARemark() {
        for journey in Journey.all {
            let remarks = journey.landmarks.dropFirst().map(\.remark)

            #expect(remarks.allSatisfy { $0?.isEmpty == false })
            #expect(journey.landmarks.first?.remark == nil)
        }
    }

    @Test
    func findsJourneyByID() {
        #expect(Journey.with(id: "tokaido") == .tokyoToKyoto)
        #expect(Journey.with(id: "unknown") == nil)
    }

    @Test
    func findsLandmarkByNameInAnyJourney() {
        #expect(Landmark.named("首里城")?.artKey == "shurijo")
        #expect(Landmark.named("どこでもない") == nil)
    }
}
