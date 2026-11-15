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
}

private extension String {
    var isASCII: Bool {
        unicodeScalars.allSatisfy(\.isASCII)
    }
}
