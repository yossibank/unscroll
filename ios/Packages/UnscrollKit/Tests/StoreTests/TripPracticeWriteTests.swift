import Core
import Foundation
@testable import Store
import Testing

struct TripPracticeWriteTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func practiceTripEndsAfterTenSecondsWithoutKilometers() throws {
        let database = try AppDatabase.inMemory()

        let trip = try database.startPracticeTrip(at: start)

        #expect(trip.isPractice)
        #expect(trip.plannedEnd == start.addingTimeInterval(10))
        #expect(trip.isActive(at: start.addingTimeInterval(9)))
        #expect(!trip.isActive(at: start.addingTimeInterval(10)))
        #expect(trip.kilometers(at: start.addingTimeInterval(60)) == 0)
    }

    @Test
    func practiceTripKeepsTheFirstJourney() throws {
        let database = try AppDatabase.inMemory()

        _ = try database.startPracticeTrip(at: start)

        #expect(try database.currentJourney() == .tokyoSightseeing)
    }

    @Test
    func completedPracticeTripDeliversThePracticeStation() throws {
        let database = try AppDatabase.inMemory()
        let trip = try database.startPracticeTrip(at: start)

        try database.recordPracticeArrivals(at: start.addingTimeInterval(11))

        let arrivals = try database.arrivals(forTrip: trip.id)

        #expect(arrivals.map(\.landmark.name) == ["おるす駅"])
        #expect(arrivals.first?.landmark.souvenir == "おるすまんじゅう")
    }

    @Test
    func stoppedPracticeTripDeliversNothing() throws {
        let database = try AppDatabase.inMemory()
        let trip = try database.startPracticeTrip(at: start)

        try database.endTrip(trip.id, at: start.addingTimeInterval(3))
        try database.recordPracticeArrivals(at: start.addingTimeInterval(11))

        #expect(try database.arrivals(forTrip: trip.id).isEmpty)
    }
}
