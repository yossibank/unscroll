import Core
import Features
import Foundation
import Store
import Testing

@MainActor
struct TripResultSheetTests {
    @Test
    func makesBodyForPlannedAndEndedTrips() throws {
        let model = try RoomModel(database: AppDatabase.inMemory())
        let start = Date(timeIntervalSince1970: 1_000_000)
        let planned = Trip(startedAt: start, plannedMinutes: 25)
        let ended = Trip(
            startedAt: start,
            plannedMinutes: 25,
            endedAt: start.addingTimeInterval(300)
        )

        _ = TripResultSheet(trip: planned, model: model, onClose: {}).body
        _ = TripResultSheet(trip: ended, model: model, onClose: {}).body
    }
}
