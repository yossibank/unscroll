import Core
import Testing

struct SouvenirTests {
    @Test
    func everyLandmarkAfterStartHasSouvenir() {
        let landmarks = Journey.tokyoToKyoto.landmarks

        #expect(landmarks.first?.souvenir == nil)
        #expect(landmarks.dropFirst().allSatisfy { $0.souvenir != nil })
    }
}
