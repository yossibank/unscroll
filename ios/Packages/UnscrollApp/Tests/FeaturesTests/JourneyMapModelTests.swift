import Features
import Foundation
import Store
import Testing

@MainActor
struct JourneyMapModelTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func startsAtNihonbashiWithoutTrips() throws {
        let model = try JourneyMapModel(database: makeDatabase(), now: { start })

        model.refresh()

        #expect(model.kilometers == 0)
        #expect(model.nextLandmark?.name == "芦ノ湖")
        #expect(model.kilometersToNext == 90)
        #expect(model.progressRatio == 0)
    }

    @Test
    func advancesAfterTrip() throws {
        let database = try makeDatabase()
        _ = try database.startTrip(minutes: 100, at: start)
        let now = start.addingTimeInterval(100 * 60)
        let model = JourneyMapModel(database: database, now: { now })

        model.refresh()

        #expect(model.kilometers == 100)
        #expect(model.nextLandmark?.name == "三保の松原")
        #expect(model.kilometersToNext == 70)
        #expect(model.progressRatio == 0.2)
    }

    @Test
    func stopsAtKyotoAfterGoingPast() throws {
        let database = try makeDatabase()
        _ = try database.startTrip(minutes: 520, at: start)
        let now = start.addingTimeInterval(520 * 60)
        let model = JourneyMapModel(database: database, now: { now })

        model.refresh()

        #expect(model.kilometers == 500)
        #expect(model.nextLandmark == nil)
        #expect(model.progressRatio == 1)
    }
}

private extension JourneyMapModelTests {
    func makeDatabase() throws -> AppDatabase {
        let database = try AppDatabase.inMemory()
        try database.selectJourney("tokaido", at: Date(timeIntervalSince1970: 0))

        return database
    }
}
