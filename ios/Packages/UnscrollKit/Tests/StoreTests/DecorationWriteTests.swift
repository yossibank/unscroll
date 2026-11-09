import Core
import Foundation
@testable import Store
import Testing

struct DecorationWriteTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)
    private let journey = Journey.tokyoToKyoto

    @Test
    func decoratesInOrderOfDecoration() throws {
        let database = try makeDatabase(minutes: 200)
        let ashinoko = journey.landmarks[1]
        let miho = journey.landmarks[2]

        try database.setDecorated(true, landmark: miho, at: start.addingTimeInterval(1))
        try database.setDecorated(true, landmark: ashinoko, at: start.addingTimeInterval(2))
        let decorated = try database.decoratedArrivals()

        #expect(decorated.map(\.landmark.name) == ["三保の松原", "芦ノ湖"])
        #expect(decorated.first?.decoratedAt == start.addingTimeInterval(1))
    }

    @Test
    func keepsFirstDateWhenDecoratedTwice() throws {
        let database = try makeDatabase(minutes: 100)
        let ashinoko = journey.landmarks[1]

        try database.setDecorated(true, landmark: ashinoko, at: start)
        try database.setDecorated(true, landmark: ashinoko, at: start.addingTimeInterval(60))

        #expect(try database.decoratedArrivals().first?.decoratedAt == start)
    }

    @Test
    func takesDown() throws {
        let database = try makeDatabase(minutes: 100)
        let ashinoko = journey.landmarks[1]

        try database.setDecorated(true, landmark: ashinoko, at: start)
        try database.setDecorated(false, landmark: ashinoko, at: start)

        #expect(try database.decoratedArrivals().isEmpty)
        #expect(try database.arrivals().count == 1)
    }

    @Test
    func ignoresLandmarkNotReached() throws {
        let database = try makeDatabase(minutes: 100)

        try database.setDecorated(true, landmark: journey.landmarks[3], at: start)

        #expect(try database.decoratedArrivals().isEmpty)
    }

    @Test
    func keepsDecorationWhenRecordingArrivalsAgain() throws {
        let database = try makeDatabase(minutes: 100)
        let now = start.addingTimeInterval(100 * 60)

        try database.setDecorated(true, landmark: journey.landmarks[1], at: now)
        try database.recordArrivals(on: journey, at: now)

        #expect(try database.decoratedArrivals().count == 1)
    }
}

private extension DecorationWriteTests {
    func makeDatabase(minutes: Int) throws -> AppDatabase {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: minutes, at: start)
        try database.recordArrivals(
            on: journey,
            at: start.addingTimeInterval(TimeInterval(minutes * 60))
        )

        return database
    }
}
