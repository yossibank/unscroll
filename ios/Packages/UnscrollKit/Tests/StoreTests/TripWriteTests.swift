import Core
import Foundation
@testable import Store
import Testing

struct TripWriteTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func startsTrip() throws {
        let database = try AppDatabase.inMemory()

        let trip = try database.startTrip(minutes: 25, at: start)

        let saved = try database.writer.read { db in
            try Trip.fetchAll(db)
        }

        #expect(saved == [trip])
        #expect(trip.startedAt == start)
        #expect(trip.plannedMinutes == 25)
        #expect(trip.endedAt == nil)
    }

    @Test
    func endsPreviousActiveTripWhenRestarting() throws {
        let database = try AppDatabase.inMemory()
        let later = start.addingTimeInterval(5 * 60)

        let first = try database.startTrip(minutes: 25, at: start)
        let second = try database.startTrip(minutes: 10, at: later)

        let saved = try database.writer.read { db in
            try Trip.fetchAll(db)
        }

        let ended = try #require(saved.first { $0.id == first.id })

        #expect(saved.count == 2)
        #expect(ended.endedAt == later)
        #expect(saved.contains(second))
    }

    @Test
    func endsActiveTrip() throws {
        let database = try AppDatabase.inMemory()
        let later = start.addingTimeInterval(5 * 60)

        let trip = try database.startTrip(minutes: 25, at: start)
        try database.endTrip(trip.id, at: later)

        let saved = try database.writer.read { db in
            try Trip.fetchOne(db, key: trip.id.description)
        }

        #expect(saved?.endedAt == later)
    }

    @Test
    func ignoresFinishedTrip() throws {
        let database = try AppDatabase.inMemory()
        let later = start.addingTimeInterval(60 * 60)

        let trip = try database.startTrip(minutes: 25, at: start)
        try database.endTrip(trip.id, at: later)

        let saved = try database.writer.read { db in
            try Trip.fetchOne(db, key: trip.id.description)
        }

        #expect(saved?.endedAt == nil)
    }
}
