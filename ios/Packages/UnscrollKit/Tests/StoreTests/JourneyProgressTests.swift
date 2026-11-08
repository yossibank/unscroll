import Core
import Foundation
@testable import Store
import Testing

struct JourneyProgressTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func isEmptyWithoutTrips() throws {
        let database = try AppDatabase.inMemory()

        let progress = try database.journeyProgress(at: start)

        #expect(progress.kilometers == 0)
        #expect(progress.activeTrip == nil)
    }

    @Test
    func countsTripInProgress() throws {
        let database = try AppDatabase.inMemory()
        let now = start.addingTimeInterval(10 * 60)

        let trip = try database.startTrip(minutes: 25, at: start)

        let progress = try database.journeyProgress(at: now)

        #expect(progress.kilometers == 10)
        #expect(progress.activeTrip == trip)
    }

    @Test
    func sumsFinishedAndEndedTrips() throws {
        let database = try AppDatabase.inMemory()
        let secondStart = start.addingTimeInterval(60 * 60)
        let secondEnd = secondStart.addingTimeInterval(7 * 60)
        let now = secondStart.addingTimeInterval(60 * 60)

        _ = try database.startTrip(minutes: 25, at: start)
        let second = try database.startTrip(minutes: 25, at: secondStart)
        try database.endTrip(second.id, at: secondEnd)

        let progress = try database.journeyProgress(at: now)

        #expect(progress.kilometers == 32)
        #expect(progress.activeTrip == nil)
    }
}
