import Features
import Store
import Testing

@MainActor
struct OnboardingViewTests {
    @Test
    func makesBody() throws {
        let database = try AppDatabase.inMemory()
        let model = OnboardingModel(database: database, settings: SettingsModel(database: database))

        _ = OnboardingView(model: model) { _ in }.body
    }
}
