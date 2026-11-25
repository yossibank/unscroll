import Core
import Store

public extension ScreenParts {
    func launchCompanion() -> Companion? {
        try? database.companion()
    }
}
