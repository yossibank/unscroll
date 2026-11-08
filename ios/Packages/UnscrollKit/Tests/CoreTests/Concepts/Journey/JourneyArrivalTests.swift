@testable import Core
import Foundation
import Testing

struct JourneyArrivalTests {
    private let journey = Journey.tokyoToKyoto
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func returnsNothingWhenNoLandmarkIsPassed() {
        let trip = Trip(startedAt: start, plannedMinutes: 25)
        let now = start.addingTimeInterval(25 * 60)

        #expect(journey.arrivals(on: trip, startingAt: 0, at: now).isEmpty)
    }

    @Test
    func returnsOneLandmark() {
        let trip = Trip(startedAt: start, plannedMinutes: 50)
        let now = start.addingTimeInterval(50 * 60)

        let arrivals = journey.arrivals(on: trip, startingAt: 60, at: now)

        #expect(arrivals.map(\.landmark.name) == ["芦ノ湖"])
        #expect(arrivals.map(\.tripID) == [trip.id])
    }

    @Test
    func returnsTwoLandmarksInOrder() {
        let trip = Trip(startedAt: start, plannedMinutes: 90)
        let now = start.addingTimeInterval(90 * 60)

        let arrivals = journey.arrivals(on: trip, startingAt: 80, at: now)

        #expect(arrivals.map(\.landmark.name) == ["芦ノ湖", "三保の松原"])
    }

    @Test
    func includesEndAndExcludesStart() {
        let trip = Trip(startedAt: start, plannedMinutes: 90)
        let now = start.addingTimeInterval(90 * 60)

        let reached = journey.arrivals(on: trip, startingAt: 0, at: now)
        let passed = journey.arrivals(
            on: Trip(startedAt: start, plannedMinutes: 50),
            startingAt: 90,
            at: now
        )

        #expect(reached.map(\.landmark.name) == ["芦ノ湖"])
        #expect(passed.isEmpty)
    }

    @Test
    func calculatesArrivalTime() throws {
        let trip = Trip(startedAt: start, plannedMinutes: 90)
        let now = start.addingTimeInterval(90 * 60)

        let arrivals = journey.arrivals(on: trip, startingAt: 60, at: now)

        let arrival = try #require(arrivals.first)

        #expect(arrival.arrivedAt == start.addingTimeInterval(30 * 60))
    }

    @Test
    func excludesStartingLandmark() {
        let trip = Trip(startedAt: start, plannedMinutes: 25)
        let now = start.addingTimeInterval(25 * 60)

        let arrivals = journey.arrivals(on: trip, startingAt: 0, at: now)

        #expect(!arrivals.contains { $0.landmark.kilometer == 0 })
    }
}
