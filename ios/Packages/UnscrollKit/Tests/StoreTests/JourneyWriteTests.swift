import Core
import Foundation
import GRDB
@testable import Store
import Testing

struct JourneyWriteTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func defaultsToTokyoToKyoto() throws {
        let database = try AppDatabase.inMemory()

        #expect(try database.currentJourney() == .tokyoToKyoto)
    }

    @Test
    func remembersSelectedJourney() throws {
        let database = try AppDatabase.inMemory()

        let isSelected = try database.selectJourney("okinawa", at: start)

        #expect(isSelected)
        #expect(try database.currentJourney() == .okinawa)
    }

    @Test
    func ignoresUnknownJourney() throws {
        let database = try AppDatabase.inMemory()

        let isSelected = try database.selectJourney("unknown", at: start)

        #expect(!isSelected)
        #expect(try database.currentJourney() == .tokyoToKyoto)
    }

    @Test
    func refusesToSwitchDuringTrip() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 25, at: start)

        let isSelected = try database.selectJourney("okinawa", at: start.addingTimeInterval(60))

        #expect(!isSelected)
        #expect(try database.currentJourney() == .tokyoToKyoto)
    }

    @Test
    func countsKilometersPerJourney() throws {
        let database = try AppDatabase.inMemory()
        let secondStart = start.addingTimeInterval(60 * 60)
        let now = secondStart.addingTimeInterval(60 * 60)

        _ = try database.startTrip(minutes: 25, at: start)
        try database.selectJourney("okinawa", at: secondStart.addingTimeInterval(-60))
        _ = try database.startTrip(minutes: 10, at: secondStart)

        #expect(try database.journeyProgress(at: now).kilometers == 10)

        try database.selectJourney("tokaido", at: now)

        #expect(try database.journeyProgress(at: now).kilometers == 25)
    }

    @Test
    func writesCurrentJourneyOnTripAndArrival() throws {
        let database = try AppDatabase.inMemory()
        let now = start.addingTimeInterval(60 * 60)

        try database.selectJourney("okinawa", at: start)
        let trip = try database.startTrip(minutes: 40, at: start)
        try database.recordArrivals(on: .okinawa, at: now)

        let tripJourney = try database.writer.read { db in
            try String.fetchOne(
                db,
                sql: "select journeyID from trip where id = ?",
                arguments: [trip.id.description]
            )
        }
        let arrivalJourneys = try database.writer.read { db in
            try String.fetchAll(db, sql: "select journeyID from arrival")
        }

        #expect(tripJourney == "okinawa")
        #expect(arrivalJourneys == ["okinawa", "okinawa"])
    }

    @Test
    func filtersArrivalsByJourney() throws {
        let database = try AppDatabase.inMemory()
        let secondStart = start.addingTimeInterval(120 * 60)
        let now = secondStart.addingTimeInterval(60 * 60)

        _ = try database.startTrip(minutes: 100, at: start)
        try database.recordArrivals(on: .tokyoToKyoto, at: secondStart)
        try database.selectJourney("okinawa", at: secondStart)
        _ = try database.startTrip(minutes: 40, at: secondStart)
        try database.recordArrivals(on: .okinawa, at: now)

        let okinawa = try database.arrivals(journeyID: "okinawa")
        let tokaido = try database.arrivals(journeyID: "tokaido")

        #expect(okinawa.map(\.landmark.name) == ["首里城", "斎場御嶽"])
        #expect(tokaido.map(\.landmark.name) == ["芦ノ湖"])
    }

    @Test
    func migratesExistingRowsToTokaido() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v5")

        try queue.write { db in
            try db.execute(
                sql: """
                insert into trip (id, startedAt, plannedMinutes)
                values ('11111111-1111-1111-1111-111111111111', ?, 25)
                """,
                arguments: [start]
            )
            try db.execute(
                sql: """
                insert into arrival (landmarkName, kilometer, tripID, arrivedAt)
                values ('芦ノ湖', 90, '11111111-1111-1111-1111-111111111111', ?)
                """,
                arguments: [start]
            )
        }

        let database = try AppDatabase(queue)

        let tripJourneys = try queue.read { db in
            try String.fetchAll(db, sql: "select journeyID from trip")
        }
        let arrivalJourneys = try queue.read { db in
            try String.fetchAll(db, sql: "select journeyID from arrival")
        }

        #expect(tripJourneys == ["tokaido"])
        #expect(arrivalJourneys == ["tokaido"])
        #expect(try database.currentJourney() == .tokyoToKyoto)
    }
}
