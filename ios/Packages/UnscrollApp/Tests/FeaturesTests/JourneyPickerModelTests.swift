import Core
import Features
import Foundation
import Store
import Testing

@MainActor
struct JourneyPickerModelTests {
    private let start = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func listsOnlyJourneysWithArt() throws {
        let model = try JourneyPickerModel(
            database: AppDatabase.inMemory(),
            now: { start },
            isAvailable: { $0.id == Journey.okinawa.id || $0.id == Journey.tokyoToKyoto.id }
        )

        #expect(model.journeys.map(\.id) == [Journey.tokyoToKyoto.id, Journey.okinawa.id])
    }

    @Test
    func listsAllJourneysWhenAllHaveArt() throws {
        let model = try JourneyPickerModel(
            database: AppDatabase.inMemory(),
            now: { start },
            isAvailable: { _ in true }
        )

        #expect(model.journeys == Journey.all)
    }

    @Test
    func countsKilometersPerJourney() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 100, at: start)

        let now = start.addingTimeInterval(100 * 60)
        let model = JourneyPickerModel(database: database, now: { now }, isAvailable: { _ in true })

        #expect(model.kilometers(of: .tokyoToKyoto) == 100)
        #expect(model.kilometers(of: .okinawa) == 0)
        #expect(!model.isOnTrip)
    }

    @Test
    func refusesToChangeDuringTrip() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 100, at: start)

        let now = start.addingTimeInterval(10 * 60)
        let model = JourneyPickerModel(database: database, now: { now }, isAvailable: { _ in true })

        model.selectedID = Journey.okinawa.id

        #expect(model.isOnTrip)
        #expect(!model.canConfirm)
        #expect(!model.confirm())
        #expect(try database.currentJourney() == .tokyoToKyoto)
    }

    @Test
    func cannotConfirmCurrentJourney() throws {
        let model = try JourneyPickerModel(
            database: AppDatabase.inMemory(),
            now: { start },
            isAvailable: { _ in true }
        )

        #expect(model.selectedID == Journey.tokyoToKyoto.id)
        #expect(!model.canConfirm)
        #expect(!model.confirm())
    }

    @Test
    func confirmChangesCurrentJourney() throws {
        let database = try AppDatabase.inMemory()
        let model = JourneyPickerModel(
            database: database,
            now: { start },
            isAvailable: { _ in true }
        )

        model.selectedID = Journey.okinawa.id

        #expect(model.confirm())
        #expect(model.currentID == Journey.okinawa.id)
        #expect(try database.currentJourney() == .okinawa)
        #expect(!model.canConfirm)
    }

    @Test
    func describesFocusTime() {
        #expect(JourneyPickerModel.focusText(kilometers: 500) == "約 8 時間")
        #expect(JourneyPickerModel.focusText(kilometers: 90) == "約 2 時間")
        #expect(JourneyPickerModel.focusText(kilometers: 59) == "約 59 分")
    }
}
