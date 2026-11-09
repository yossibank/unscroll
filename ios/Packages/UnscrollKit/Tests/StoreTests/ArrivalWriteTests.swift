import Core
import Foundation
@testable import Store
import Testing

struct ArrivalWriteTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)
    private let journey = Journey.tokyoToKyoto

    @Test
    func addsKilometersOfEarlierTrips() throws {
        let database = try AppDatabase.inMemory()
        let first = try database.startTrip(minutes: 60, at: start)
        let secondStart = start.addingTimeInterval(60 * 60)
        let second = try database.startTrip(minutes: 50, at: secondStart)
        let now = secondStart.addingTimeInterval(50 * 60)

        try database.recordArrivals(on: journey, at: now)
        let arrivals = try database.arrivals(forTrip: second.id)

        #expect(first.id != second.id)
        #expect(arrivals.map(\.landmark.name) == ["芦ノ湖"])
        #expect(arrivals.first?.arrivedAt == secondStart.addingTimeInterval(30 * 60))
        #expect(arrivals.first?.tripID == second.id)
    }

    @Test
    func recordsEarlierTripMissedBefore() throws {
        let database = try AppDatabase.inMemory()
        let first = try database.startTrip(minutes: 90, at: start)
        let secondStart = start.addingTimeInterval(120 * 60)
        _ = try database.startTrip(minutes: 25, at: secondStart)
        let now = secondStart.addingTimeInterval(10 * 60)

        try database.recordArrivals(on: journey, at: now)

        let arrivals = try database.arrivals(forTrip: first.id)
        #expect(arrivals.map(\.landmark.name) == ["芦ノ湖"])
    }

    @Test
    func doesNotDuplicateWhenCalledTwice() throws {
        let database = try AppDatabase.inMemory()
        let trip = try database.startTrip(minutes: 90, at: start)
        let now = start.addingTimeInterval(90 * 60)

        try database.recordArrivals(on: journey, at: now)
        let first = try database.arrivals(forTrip: trip.id)
        try database.recordArrivals(on: journey, at: now)
        let second = try database.arrivals(forTrip: trip.id)
        let saved = try database.arrivals(forTrip: trip.id)

        #expect(first.count == 1)
        #expect(second == first)
        #expect(saved == first)
    }

    @Test
    func listsArrivalsOfEveryTripInJourneyOrder() throws {
        let database = try AppDatabase.inMemory()
        let first = try database.startTrip(minutes: 90, at: start)
        let secondStart = start.addingTimeInterval(120 * 60)
        let second = try database.startTrip(minutes: 90, at: secondStart)
        let now = secondStart.addingTimeInterval(90 * 60)

        try database.recordArrivals(on: journey, at: now)
        let arrivals = try database.arrivals()

        #expect(arrivals.map(\.landmark.name) == ["芦ノ湖", "三保の松原"])
        #expect(arrivals.map(\.tripID) == [first.id, second.id])
    }

    @Test
    func recordsOnlyDistanceTravelledWhenEndedEarly() throws {
        let database = try AppDatabase.inMemory()
        let trip = try database.startTrip(minutes: 90, at: start)
        let endedAt = start.addingTimeInterval(60 * 60)
        try database.endTrip(trip.id, at: endedAt)
        let ended = try #require(
            database.writer.read { db in
                try Trip.fetchOne(db, key: trip.id.description)
            }
        )
        let now = start.addingTimeInterval(120 * 60)

        try database.recordArrivals(on: journey, at: now)
        let arrivals = try database.arrivals(forTrip: ended.id)

        #expect(arrivals.isEmpty)
    }
}
