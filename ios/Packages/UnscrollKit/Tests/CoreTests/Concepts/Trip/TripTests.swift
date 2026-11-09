@testable import Core
import Foundation
import Testing

struct TripTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func countsMinutesInProgress() {
        let trip = Trip(startedAt: start, plannedMinutes: 25)
        let now = start.addingTimeInterval(10 * 60 + 59)

        #expect(trip.isActive(at: now))
        #expect(trip.focusedMinutes(at: now) == 10)
        #expect(trip.kilometers(at: now) == 10)
    }

    @Test
    func stopsAtPlannedEnd() {
        let trip = Trip(startedAt: start, plannedMinutes: 25)
        let now = start.addingTimeInterval(60 * 60)

        #expect(!trip.isActive(at: now))
        #expect(trip.focusedMinutes(at: now) == 25)
        #expect(trip.kilometers(at: now) == 25)
    }

    @Test
    func stopsAtEndedAt() {
        let ended = start.addingTimeInterval(7 * 60)
        let trip = Trip(startedAt: start, plannedMinutes: 25, endedAt: ended)
        let now = start.addingTimeInterval(20 * 60)

        #expect(!trip.isActive(at: now))
        #expect(trip.focusedMinutes(at: now) == 7)
        #expect(trip.kilometers(at: now) == 7)
    }

    @Test
    func isZeroBeforeStart() {
        let trip = Trip(startedAt: start, plannedMinutes: 25)
        let now = start.addingTimeInterval(-300)

        #expect(trip.focusedMinutes(at: now) == 0)
        #expect(trip.kilometers(at: now) == 0)
    }

    @Test
    func handlesBoundaries() {
        let trip = Trip(startedAt: start, plannedMinutes: 25)

        #expect(trip.focusedMinutes(at: start) == 0)
        #expect(trip.isActive(at: start))
        #expect(trip.focusedMinutes(at: trip.plannedEnd) == 25)
        #expect(!trip.isActive(at: trip.plannedEnd))
    }
}
