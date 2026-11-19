import Core
import DesignSystem
import Features
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
        let model = RoomModel(database: database, defaults: defaults, now: { fixedNow })

        model.look = RoomLook(wall: .stars, floor: .tatami)
        let relaunched = RoomModel(database: database, defaults: defaults, now: { fixedNow })

        #expect(relaunched.look == RoomLook(wall: .stars, floor: .tatami))
    }

    @Test
    func startsWithPlasterAndWood() throws {
        let model = try RoomModel(database: makeDatabase(), defaults: makeDefaults())

        #expect(model.look == RoomLook(wall: .plaster, floor: .wood))
    }

    @Test
    func hangsPostcardsInTappedOrder() throws {
        var current = fixedNow
        let model = try makeModel { current }
        let names = model.journey.landmarks.map(\.name)

        model.toggleHung(model.journey.landmarks[3])
        current += 1
        model.toggleHung(model.journey.landmarks[1])

        #expect(model.hungPostcards.map(\.name) == [names[3], names[1]])

        current += 1
        model.toggleHung(model.journey.landmarks[2])

        #expect(model.hungPostcards.map(\.name) == [names[1], names[2]])

        current += 1
        model.toggleHung(model.journey.landmarks[1])

        #expect(model.hungPostcards.map(\.name) == [names[2]])
    }

    @Test
    func restoresOrderOfPostcards() throws {
        var current = fixedNow
        let model = try makeModel { current }
        let first = model.journey.landmarks[1]
        let third = model.journey.landmarks[3]

        model.hang([third, first])
        current += 1
        model.hang([first, third])

        #expect(model.hungPostcards == [first, third])
    }

    @Test
    func restoresPostcardsBeyondString() throws {
        var current = fixedNow
        let model = try makeModel { current }
        let landmarks = Array(model.journey.landmarks[1...3])

        model.hang(landmarks)
        current += 1
        model.toggleHung(landmarks[2])

        #expect(model.decoratedArrivals.map(\.landmark) == [landmarks[1]])

        current += 1
        model.hang(landmarks)

        #expect(model.decoratedArrivals.map(\.landmark) == landmarks)
    }

    @Test
    func keepsTappedOrderWhenClockGoesBack() throws {
        var current = fixedNow
        let model = try makeModel { current }
        let first = model.journey.landmarks[1]
        let second = model.journey.landmarks[2]

        model.toggleHung(first)
        current -= 60
        model.toggleHung(second)

        #expect(model.hungPostcards == [first, second])
    }

    @Test
    func ignoresPostcardNotArrived() throws {
        let model = try makeModel { fixedNow }

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

    func makeModel(now: @escaping @MainActor () -> Date) throws -> RoomModel {
        let database = try makeDatabase()
        _ = try database.startTrip(minutes: 300, at: fixedNow.addingTimeInterval(-310 * 60))
        let model = RoomModel(database: database, defaults: makeDefaults(), now: now)
        model.refresh()
        return model
    }

    func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString) ?? .standard
    }
}
