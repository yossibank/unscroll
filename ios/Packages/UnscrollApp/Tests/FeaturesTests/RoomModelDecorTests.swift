import Core
import DesignSystem
import FeatureModels
import Foundation
import Store
import Testing

@MainActor
struct RoomModelDecorTests {
    private let fixedNow = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func keepsLookAfterRelaunch() throws {
        let database = try makeDatabase()
        let defaults = makeDefaults()
        let model = RoomModel(parts: .fixed(database, at: fixedNow), defaults: defaults)

        model.look = RoomLook(wall: .stars, floor: .tatami)
        let relaunched = RoomModel(parts: .fixed(database, at: fixedNow), defaults: defaults)

        #expect(relaunched.look == RoomLook(wall: .stars, floor: .tatami))
    }

    @Test
    func startsWithPlasterAndWood() throws {
        let model = try RoomModel(parts: .system(makeDatabase()), defaults: makeDefaults())

        #expect(model.look == RoomLook(wall: .plaster, floor: .wood))
    }

    @Test
    func hangsPostcardsInTappedOrder() throws {
        let time = MovingClock(fixedNow)
        let model = try makeModel(clock: time.clock)
        let names = model.journey.landmarks.map(\.name)

        model.toggleHung(model.journey.landmarks[3])
        time.advance(by: 1)
        model.toggleHung(model.journey.landmarks[1])

        #expect(model.hungPostcards.map(\.name) == [names[3], names[1]])

        time.advance(by: 1)
        model.toggleHung(model.journey.landmarks[2])

        #expect(model.hungPostcards.map(\.name) == [names[1], names[2]])

        time.advance(by: 1)
        model.toggleHung(model.journey.landmarks[1])

        #expect(model.hungPostcards.map(\.name) == [names[2]])
    }

    @Test
    func restoresOrderOfPostcards() throws {
        let time = MovingClock(fixedNow)
        let model = try makeModel(clock: time.clock)
        let first = model.journey.landmarks[1]
        let third = model.journey.landmarks[3]

        model.hang([third, first])
        time.advance(by: 1)
        model.hang([first, third])

        #expect(model.hungPostcards == [first, third])
    }

    @Test
    func restoresPostcardsBeyondString() throws {
        let time = MovingClock(fixedNow)
        let model = try makeModel(clock: time.clock)
        let landmarks = Array(model.journey.landmarks[1...3])

        model.hang(landmarks)
        time.advance(by: 1)
        model.toggleHung(landmarks[2])

        #expect(model.decoratedArrivals.map(\.landmark) == [landmarks[1]])

        time.advance(by: 1)
        model.hang(landmarks)

        #expect(model.decoratedArrivals.map(\.landmark) == landmarks)
    }

    @Test
    func keepsTappedOrderWhenClockGoesBack() throws {
        let time = MovingClock(fixedNow)
        let model = try makeModel(clock: time.clock)
        let first = model.journey.landmarks[1]
        let second = model.journey.landmarks[2]

        model.toggleHung(first)
        time.advance(by: -60)
        model.toggleHung(second)

        #expect(model.hungPostcards == [first, second])
    }

    @Test
    func ignoresPostcardNotArrived() throws {
        let model = try makeModel(clock: .fixed(fixedNow))

        model.toggleHung(model.journey.landmarks[4])

        #expect(model.hungPostcards.isEmpty)
    }
}

private extension RoomModelDecorTests {
    func makeDatabase() throws -> AppDatabase {
        let database = try AppDatabase.inMemory()
        try database.selectJourney("tokaido", at: Date(timeIntervalSince1970: 0))

        return database
    }

    func makeModel(clock: ScreenClock) throws -> RoomModel {
        let database = try makeDatabase()
        _ = try database.startTrip(minutes: 300, at: fixedNow.addingTimeInterval(-310 * 60))
        let model = RoomModel(parts: ScreenParts(database: database, clock: clock), defaults: makeDefaults())
        model.refresh()
        return model
    }

    func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString) ?? .standard
    }
}
