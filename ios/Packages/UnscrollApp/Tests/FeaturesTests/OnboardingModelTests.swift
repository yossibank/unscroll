@testable import Features
import Store
import Testing

@MainActor
struct OnboardingModelTests {
    @Test
    func startsAtTheFirstIntro() throws {
        let model = try makeModel()

        #expect(model.page == .travel)
        #expect(model.isIntro)
        #expect(!model.canGoBack)
        #expect(model.canSkipIntro)
        #expect(model.setupStep == nil)
    }

    @Test
    func turnsPagesInOrder() throws {
        let model = try makeModel()

        model.next()
        model.next()
        model.next()

        #expect(model.page == .usage)
        #expect(!model.canSkipIntro)

        model.back()

        #expect(model.page == .postcard)
    }

    @Test
    func skipsIntroToCompanion() throws {
        let model = try makeModel()

        model.skipIntro()

        #expect(model.page == .companion)
        #expect(model.setupStep == 1)
        #expect(!model.canSwipeForward)
    }

    @Test
    func stopsAtTheLastPage() throws {
        let model = try makeModel()

        for _ in OnboardingModel.Page.allCases {
            model.next()
        }

        #expect(model.page == .apps)
        #expect(model.setupStep == 3)
    }

    @Test
    func savesCompanionAndMovesOn() throws {
        let database = try AppDatabase.inMemory()
        let settings = SettingsModel(database: database)
        let model = OnboardingModel(database: database, settings: settings)

        model.skipIntro()
        model.saveCompanion()

        #expect(model.page == .permission)
        #expect(try database.companion() != nil)
        #expect(settings.companion != nil)
    }

    @Test
    func staysOnCompanionWhenNameIsEmpty() throws {
        let model = try makeModel()

        model.skipIntro()
        model.companion.rename("   ")
        model.saveCompanion()

        #expect(model.page == .companion)
    }
}

private extension OnboardingModelTests {
    func makeModel() throws -> OnboardingModel {
        let database = try AppDatabase.inMemory()
        return OnboardingModel(database: database, settings: SettingsModel(database: database))
    }
}
