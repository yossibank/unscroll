import Core
import FamilyControls
@testable import Features
import Foundation
import Store
import Testing

@MainActor
struct SettingsModelTests {
    @Test
    func showsUnselectedWhenNoAppsAreChosen() throws {
        let model = try SettingsModel(database: AppDatabase.inMemory())

        model.selection = FamilyActivitySelection()

        #expect(!model.hasSelection)
        #expect(!model.isReady)
        #expect(model.selectionSummary == "未選択")
    }

    @Test
    func addsKilometersOfEveryJourney() throws {
        let database = try AppDatabase.inMemory()
        let start = Date.now.addingTimeInterval(-3 * 60 * 60)

        _ = try database.selectJourney(Journey.tokyoToKyoto.id, at: start)
        _ = try database.startTrip(minutes: 30, at: start.addingTimeInterval(60))
        _ = try database.selectJourney(Journey.worldHeritage.id, at: start.addingTimeInterval(3600))
        _ = try database.startTrip(minutes: 20, at: start.addingTimeInterval(3660))

        let model = SettingsModel(database: database)

        #expect(model.kilometersTogether == 50 * Trip.kilometersPerMinute)
    }
}
