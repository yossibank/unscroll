import Core
import FeatureModels
import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    let state = State()

    let dependencies: Dependencies

    init(open: @escaping @MainActor () throws -> ScreenParts) {
        self.dependencies = Dependencies(open: open)
    }
}

extension AppModel {
    enum Launch {
        case opening
        case ready(ScreenParts)
        case failed(String)
    }

    @MainActor
    @Observable
    final class State {
        fileprivate(set) var launch: Launch = .opening
        fileprivate(set) var companion: Companion?
    }

    struct Dependencies {
        let open: @MainActor () throws -> ScreenParts
    }

    func open() {
        guard case .opening = state.launch else {
            return
        }

        do {
            let parts = try dependencies.open()
            state.companion = parts.launchCompanion()
            state.launch = .ready(parts)
        } catch {
            state.launch = .failed(error.localizedDescription)
        }
    }

    func suspend() {
        ScreenParts.suspendDatabase()
    }

    func resume() {
        ScreenParts.resumeDatabase()
    }
}
