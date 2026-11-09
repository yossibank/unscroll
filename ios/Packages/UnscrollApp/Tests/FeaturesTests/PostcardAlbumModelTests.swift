import Features
import Foundation
import Store
import Testing

@MainActor
struct PostcardAlbumModelTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func hasNoPostcardsWithoutTrips() throws {
        let model = try PostcardAlbumModel(database: AppDatabase.inMemory(), now: { start })

        #expect(model.collectedCount == 0)
        #expect(model.totalCount == 6)
        #expect(model.entries.first?.landmark.name == "芦ノ湖")
        #expect(model.entries.first?.remainingKilometers == 90)
        #expect(model.entries.last?.remainingKilometers == 500)
    }

    @Test
    func collectsPostcardAfterTrip() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 100, at: start)
        let now = start.addingTimeInterval(100 * 60)
        let model = PostcardAlbumModel(database: database, now: { now })

        let first = try #require(model.entries.first)
        let second = try #require(model.entries.dropFirst().first)

        #expect(model.collectedCount == 1)
        #expect(first.isCollected)
        #expect(first.arrival?.arrivedAt == start.addingTimeInterval(90 * 60))
        #expect(!second.isCollected)
        #expect(second.remainingKilometers == 70)
    }

    @Test
    func waitsForTripToEndBeforeCollecting() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 120, at: start)
        let now = start.addingTimeInterval(100 * 60)
        let model = PostcardAlbumModel(database: database, now: { now })

        let first = try #require(model.entries.first)

        #expect(model.collectedCount == 0)
        #expect(!first.isCollected)
        #expect(first.remainingKilometers == 0)
    }

    @Test
    func collectsEveryPostcardAtKyoto() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 520, at: start)
        let now = start.addingTimeInterval(520 * 60)
        let model = PostcardAlbumModel(database: database, now: { now })

        #expect(model.collectedCount == 6)
        #expect(model.entries.allSatisfy { $0.remainingKilometers == 0 })
    }

    @Test
    func decoratesCollectedPostcard() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 100, at: start)
        let now = start.addingTimeInterval(100 * 60)
        let model = PostcardAlbumModel(database: database, now: { now })
        let landmark = model.journey.landmarks[1]

        model.setDecorated(true, landmark: landmark)

        #expect(model.arrival(at: landmark)?.isDecorated == true)
        #expect(try database.decoratedArrivals().count == 1)

        model.setDecorated(false, landmark: landmark)

        #expect(model.arrival(at: landmark)?.isDecorated == false)
    }
}
