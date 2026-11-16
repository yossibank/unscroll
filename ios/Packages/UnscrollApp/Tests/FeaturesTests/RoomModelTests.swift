import Core
import Features
import Foundation
import Store
import Testing

@MainActor
struct RoomModelTests {
    private let fixedNow = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func decoratesArrivalFromFinishedTrip() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 90, at: fixedNow.addingTimeInterval(-100 * 60))
        let model = RoomModel(database: database, defaults: makeDefaults(), now: { fixedNow })
        let landmark = model.journey.landmarks[1]

        model.refresh()
        #expect(model.decoratedArrivals.isEmpty)

        model.setDecorated(true, landmark: landmark)

        #expect(model.decoratedArrivals.map(\.landmark.name) == ["芦ノ湖"])
    }

    @Test
    func listsArrivalsWithoutDecorating() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 90, at: fixedNow.addingTimeInterval(-100 * 60))
        let model = RoomModel(database: database, defaults: makeDefaults(), now: { fixedNow })

        model.refresh()

        #expect(model.arrivals.map(\.landmark.name) == ["芦ノ湖"])
        #expect(model.decoratedArrivals.isEmpty)
    }

    @Test
    func showsActiveTrip() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 25, at: fixedNow.addingTimeInterval(-5 * 60))
        let model = RoomModel(database: database, defaults: makeDefaults(), now: { fixedNow })

        model.refresh()

        #expect(model.progress?.kilometers == 5)
        #expect(model.tripEndsAt != nil)
        #expect(!model.canStart)
    }

    @Test
    func hasNoEndWithoutTrip() throws {
        let model = try RoomModel(
            database: AppDatabase.inMemory(),
            defaults: makeDefaults(),
            now: { fixedNow }
        )

        model.refresh()

        #expect(model.tripEndsAt == nil)
    }

    @Test
    func savesSelectedMinutes() throws {
        let database = try AppDatabase.inMemory()
        let defaults = makeDefaults()
        let model = RoomModel(database: database, defaults: defaults, now: { fixedNow })

        model.selectedMinutes = 50

        let reopened = RoomModel(database: database, defaults: defaults, now: { fixedNow })

        #expect(reopened.selectedMinutes == 50)
    }

    @Test
    func fallsBackToDefaultMinutes() throws {
        let defaults = makeDefaults()
        defaults.set(33, forKey: "room.selectedMinutes")

        let model = try RoomModel(
            database: AppDatabase.inMemory(),
            defaults: defaults,
            now: { fixedNow }
        )

        #expect(model.selectedMinutes == 25)
    }

    @Test
    func fallsBackWhenSavedMinutesAreTooLong() throws {
        let defaults = makeDefaults()
        defaults.set(300, forKey: "room.selectedMinutes")

        let model = try RoomModel(
            database: AppDatabase.inMemory(),
            defaults: defaults,
            now: { fixedNow }
        )

        #expect(model.selectedMinutes == 25)
    }

    @Test
    func stepsTripLengthByFiveMinutes() throws {
        let model = try RoomModel(
            database: AppDatabase.inMemory(),
            defaults: makeDefaults(),
            now: { fixedNow }
        )

        model.selectedMinutes = 25
        model.lengthen()

        #expect(model.selectedMinutes == 30)

        model.shorten()
        model.shorten()

        #expect(model.selectedMinutes == 20)
    }

    @Test
    func stopsTripLengthAtTheLongestEnd() throws {
        let model = try RoomModel(
            database: AppDatabase.inMemory(),
            defaults: makeDefaults(),
            now: { fixedNow }
        )

        model.selectedMinutes = 180
        model.lengthen()

        #expect(model.selectedMinutes == 180)
        #expect(!model.canLengthen)
    }

    @Test
    func stopsTripLengthAtTheShortestEnd() throws {
        let model = try RoomModel(
            database: AppDatabase.inMemory(),
            defaults: makeDefaults(),
            now: { fixedNow }
        )

        model.selectedMinutes = RoomModel.tripRange.lowerBound
        model.shorten()

        #expect(model.selectedMinutes == RoomModel.tripRange.lowerBound)
        #expect(!model.canShorten)
    }

    @Test
    func notesLandmarkForLength() throws {
        let database = try AppDatabase.inMemory()
        let start = fixedNow.addingTimeInterval(-100 * 60)
        let trip = try database.startTrip(minutes: 90, at: start)
        try database.endTrip(trip.id, at: start.addingTimeInterval(62 * 60))
        let model = RoomModel(database: database, defaults: makeDefaults(), now: { fixedNow })

        #expect(model.progress?.kilometers == 62)
        #expect(model.lengthNote(for: 50) == "芦ノ湖に着く")
        #expect(model.lengthNote(for: 25) == "+25 km")
        #expect(model.nextLandmark?.name == "芦ノ湖")
        #expect(model.kilometersToNext == 28)
    }

    @Test
    func showsFinishedTripOnceUntilAcknowledged() throws {
        let database = try AppDatabase.inMemory()
        let defaults = makeDefaults()
        let model = RoomModel(database: database, defaults: defaults, now: { fixedNow })

        #expect(model.finishedTrip == nil)

        let start = fixedNow.addingTimeInterval(-30 * 60)
        let trip = try database.startTrip(minutes: 25, at: start)

        model.refresh()

        #expect(model.finishedTrip == trip)

        model.acknowledgeFinishedTrip()

        #expect(model.finishedTrip == nil)

        let reopened = RoomModel(database: database, defaults: defaults, now: { fixedNow })

        #expect(reopened.finishedTrip == nil)
    }

    @Test
    func showsArrivalsOfFinishedTrip() throws {
        let database = try AppDatabase.inMemory()
        let model = RoomModel(database: database, defaults: makeDefaults(), now: { fixedNow })

        let start = fixedNow.addingTimeInterval(-100 * 60)
        _ = try database.startTrip(minutes: 90, at: start)

        model.refresh()

        #expect(model.finishedArrivals.map(\.landmark.name) == ["芦ノ湖"])
        #expect(model.finishedArrivals.first?.arrivedAt == start.addingTimeInterval(90 * 60))

        model.refresh()

        #expect(model.finishedArrivals.count == 1)

        model.acknowledgeFinishedTrip()
        model.refresh()

        #expect(model.finishedArrivals.isEmpty)
    }

    @Test
    func skipsExistingTripOnFirstLaunch() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 25, at: fixedNow.addingTimeInterval(-60 * 60))

        let model = RoomModel(database: database, defaults: makeDefaults(), now: { fixedNow })

        #expect(model.finishedTrip == nil)
    }
}

private extension RoomModelTests {
    func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString) ?? .standard
    }
}
