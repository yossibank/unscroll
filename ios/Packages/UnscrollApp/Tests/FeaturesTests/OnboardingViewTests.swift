import FeatureModels
import Features
import Store
import Testing

@MainActor
struct OnboardingViewTests {
    @Test
    func makesBody() throws {
        let database = try AppDatabase.inMemory()
        let model = OnboardingModel(parts: .system(database), settings: SettingsModel(parts: .system(database)))

        _ = OnboardingView(model: model) { _ in }.body
    }
}
