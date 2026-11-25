import Core
import FeatureModels
import Foundation
import Store
import Testing

@MainActor
struct JourneyPickerModelTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func listsOnlyJourneysWithArt() throws {
        let model = try JourneyPickerModel(
            parts: .fixed(makeDatabase(), at: start),
            isAvailable: { $0.id == Journey.okinawa.id || $0.id == Journey.tokyoToKyoto.id }
        )

        #expect(model.journeys.map(\.id) == [Journey.tokyoToKyoto.id, Journey.okinawa.id])
    }

    @Test
    func listsAllJourneysWhenAllHaveArt() throws {
        let model = try JourneyPickerModel(
            parts: .fixed(makeDatabase(), at: start),
            isAvailable: { _ in true }
        )

        #expect(model.journeys == Journey.all)
    }

    @Test
    func countsKilometersPerJourney() throws {
        let database = try makeDatabase()
        _ = try database.startTrip(minutes: 100, at: start)

        let now = start.addingTimeInterval(100 * 60)
        let model = JourneyPickerModel(parts: .fixed(database, at: now), isAvailable: { _ in true })

        #expect(model.kilometers(of: .tokyoToKyoto) == 100)
        #expect(model.kilometers(of: .okinawa) == 0)
        #expect(!model.isOnTrip)
    }

    @Test
    func refusesToChangeDuringTrip() throws {
        let database = try makeDatabase()
        _ = try database.startTrip(minutes: 100, at: start)

        let now = start.addingTimeInterval(10 * 60)
        let model = JourneyPickerModel(parts: .fixed(database, at: now), isAvailable: { _ in true })

        model.selectedID = Journey.okinawa.id

        #expect(model.isOnTrip)
        #expect(!model.canConfirm)
        #expect(!model.confirm())
        #expect(try database.currentJourney() == .tokyoToKyoto)
    }

    @Test
    func cannotConfirmCurrentJourney() throws {
        let model = try JourneyPickerModel(
            parts: .fixed(makeDatabase(), at: start),
            isAvailable: { _ in true }
        )

        #expect(model.selectedID == Journey.tokyoToKyoto.id)
        #expect(!model.canConfirm)
        #expect(!model.confirm())
    }

    @Test
    func confirmChangesCurrentJourney() throws {
        let database = try makeDatabase()
        let model = JourneyPickerModel(
            parts: .fixed(database, at: start),
            isAvailable: { _ in true }
        )

        model.selectedID = Journey.okinawa.id

        #expect(model.confirm())
        #expect(model.currentID == Journey.okinawa.id)
        #expect(try database.currentJourney() == .okinawa)
        #expect(!model.canConfirm)
    }

    @Test
    func showsOpenJourneysFirst() throws {
        let model = try JourneyPickerModel(
            parts: .fixed(makeDatabase(), at: start),
            isAvailable: { _ in true }
        )

        #expect(model.filter == .open)
        #expect(model.shownJourneys == Journey.all)
        #expect(model.count(.finished) == 0)
    }

    @Test
    func sortsFinishedJourneysApart() throws {
        let database = try makeDatabase()
        let journey = Journey.tokyoSightseeing
        try database.selectJourney(journey.id, at: start)
        _ = try database.startTrip(minutes: journey.totalKilometers, at: start)

        let now = start.addingTimeInterval(Double(journey.totalKilometers) * 60)
        let model = JourneyPickerModel(parts: .fixed(database, at: now), isAvailable: { _ in true })

        #expect(model.isFinished(journey))
        #expect(!model.shownJourneys.contains(journey))

        model.filter = .finished

        #expect(model.shownJourneys == [journey])
        #expect(model.count(.open) == Journey.all.count - 1)

        model.filter = .all

        #expect(model.shownJourneys == Journey.all)
    }

    @Test
    func describesFocusTime() {
        #expect(JourneyPickerModel.focusText(kilometers: 500) == "約 8 時間")
        #expect(JourneyPickerModel.focusText(kilometers: 90) == "約 2 時間")
        #expect(JourneyPickerModel.focusText(kilometers: 59) == "約 59 分")
    }
}

private extension JourneyPickerModelTests {
    func makeDatabase() throws -> AppDatabase {
        let database = try AppDatabase.inMemory()
        try database.selectJourney("tokaido", at: Date(timeIntervalSince1970: 0))

        return database
    }
}
