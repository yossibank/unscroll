@testable import AppFeature
import FeatureModels
import Foundation
import Store
import Testing

@MainActor
struct AppModelTests {
    @Test
    func startsOpening() {
        let model = AppModel {
            try Self.makeParts()
        }

        #expect(model.state.launch.name == "opening")
        #expect(model.state.companion == nil)
    }

    @Test
    func becomesReadyWhenDatabaseOpens() {
        let model = AppModel {
            try Self.makeParts()
        }

        model.open()

        #expect(model.state.launch.name == "ready")
    }

    @Test
    func failsWhenDatabaseDoesNotOpen() {
        let model = AppModel {
            throw AppDatabase.SetupError.appGroupUnavailable
        }

        model.open()

        #expect(model.state.launch.name == "failed")
    }
}

private extension AppModelTests {
    static func makeParts() throws -> ScreenParts {
        let database = try AppDatabase.inMemory()
        let now = Date(timeIntervalSince1970: 1_791_000_000)
        return ScreenParts(database: database, clock: .fixed(now))
    }
}

private extension AppModel.Launch {
    var name: String {
        switch self {
        case .opening: "opening"
        case .ready: "ready"
        case .failed: "failed"
        }
    }
}
