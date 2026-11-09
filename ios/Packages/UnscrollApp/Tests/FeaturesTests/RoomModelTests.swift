import Features
import Foundation
import Store
import Testing

@MainActor
struct RoomModelTests {
    @Test
    func showsActiveTrip() throws {
        let database = try AppDatabase.inMemory()
        _ = try database.startTrip(minutes: 25, at: .now.addingTimeInterval(-5 * 60))
        let model = RoomModel(database: database)

        model.refresh()

        #expect(model.progress?.kilometers == 5)
        #expect(model.tripEndsAt != nil)
        #expect(!model.canStart)
    }

    @Test
    func hasNoEndWithoutTrip() throws {
        let model = try RoomModel(database: AppDatabase.inMemory())

        model.refresh()

        #expect(model.tripEndsAt == nil)
    }
}
