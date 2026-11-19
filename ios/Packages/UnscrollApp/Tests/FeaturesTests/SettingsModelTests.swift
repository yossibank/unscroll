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
    func addsRenamesAndDeletesASet() throws {
        clearSets()

        defer {
            clearSets()
        }

        let model = try SettingsModel(database: AppDatabase.inMemory())
        let before = model.sets.count

        model.addSet(named: "  勉強中  ")

        let added = try #require(model.sets.last)

        #expect(model.sets.count == before + 1)
        #expect(added.name == "勉強中")
        #expect(model.activeSetID == added.id)
        #expect(!model.hasSelection)

        model.renameSet(added.id, to: " ")

        #expect(model.sets.last?.name == "勉強中")

        model.deleteSet(added.id)

        #expect(model.sets.count == before)
        #expect(model.activeSetID == model.sets.first?.id)
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

private extension SettingsModelTests {
    func clearSets() {
        let defaults = UserDefaults(suiteName: ScreenTimeShared.appGroup)
        defaults?.removeObject(forKey: BlockedApps.setsKey)
        defaults?.removeObject(forKey: BlockedApps.activeSetKey)
    }
}
