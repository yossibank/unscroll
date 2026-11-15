import Core
import Testing

struct LandmarkArtTests {
    @Test
    func everyLandmarkHasItsOwnArt() {
        let names = Journey.tokyoToKyoto.landmarks.map(\.artName)

        #expect(Set(names).count == names.count)
        #expect(names.allSatisfy { $0.hasPrefix("landmark_") && $0.isASCII })
    }

    @Test
    func souvenirArtFollowsSouvenir() {
        let landmarks = Journey.tokyoToKyoto.landmarks

        #expect(landmarks.allSatisfy { ($0.souvenir == nil) == ($0.souvenirArtName == nil) })
        #expect(landmarks.compactMap(\.souvenirArtName).allSatisfy { $0.hasPrefix("souvenir_") })
    }

    @Test
    func sceneryArtNamesEachLayer() throws {
        let landmark = try #require(Journey.tokyoToKyoto.landmarks.last)
        let names = SceneryLayer.allCases.map { landmark.sceneryArtName($0) }

        #expect(names == ["trip_kiyomizu_far", "trip_kiyomizu_mid", "trip_kiyomizu_near"])
    }
}

private extension String {
    var isASCII: Bool {
        unicodeScalars.allSatisfy(\.isASCII)
    }
}
