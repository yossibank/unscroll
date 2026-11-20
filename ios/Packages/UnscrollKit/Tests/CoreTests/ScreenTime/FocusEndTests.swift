import Core
import Foundation
import Testing

struct FocusEndTests {
    private let now = Date(timeIntervalSince1970: 1_000_000)

    @Test
    func keepsTheNextTripWhenAnOldWatchEnds() {
        let endsAt = now.addingTimeInterval(60 * 60)
        #expect(!FocusEnd.hasEnded(endsAt: endsAt, at: now))
    }

    @Test
    func endsWhenTheTripTimeHasPassed() {
        let endsAt = now.addingTimeInterval(-1)
        #expect(FocusEnd.hasEnded(endsAt: endsAt, at: now))
    }

    @Test
    func endsWhenTheWarningComesSlightlyEarly() {
        let endsAt = now.addingTimeInterval(FocusEnd.toleranceSeconds)
        #expect(FocusEnd.hasEnded(endsAt: endsAt, at: now))
    }

    @Test
    func endsWhenNoTripIsSaved() {
        #expect(FocusEnd.hasEnded(endsAt: nil, at: now))
    }

    @Test
    func keepsTheNewTripWhenTheOldWatchIsStopped() {
        let entry = FocusEndFile.Entry(endsAt: now.addingTimeInterval(-60), activity: "focus.new")
        #expect(!FocusEnd.shouldEnd(entry, activity: "focus.old", at: now))
    }

    @Test
    func endsWhenTheTripWatchEnds() {
        let entry = FocusEndFile.Entry(endsAt: now.addingTimeInterval(-1), activity: "focus.new")
        #expect(FocusEnd.shouldEnd(entry, activity: "focus.new", at: now))
    }

    @Test
    func keepsTheTripBeforeItsEnd() {
        let entry = FocusEndFile.Entry(endsAt: now.addingTimeInterval(60), activity: "focus.new")
        #expect(!FocusEnd.shouldEnd(entry, activity: "focus.new", at: now))
    }

    @Test
    func endsWhenNoEntryIsSaved() {
        #expect(FocusEnd.shouldEnd(nil, activity: "focus.old", at: now))
    }

    @Test
    func findsAShieldLeftAfterTheTripEnded() {
        let endsAt = now.addingTimeInterval(-60)
        #expect(FocusEnd.isLeftOver(endsAt: endsAt, hasActiveTrip: false, at: now))
    }

    @Test
    func keepsTheShieldDuringATrip() {
        let endsAt = now.addingTimeInterval(-60)
        #expect(!FocusEnd.isLeftOver(endsAt: endsAt, hasActiveTrip: true, at: now))
    }

    @Test
    func keepsTheShieldBeforeTheEnd() {
        let endsAt = now.addingTimeInterval(60)
        #expect(!FocusEnd.isLeftOver(endsAt: endsAt, hasActiveTrip: false, at: now))
    }

    @Test
    func findsNothingWhenNoEndIsSaved() {
        #expect(!FocusEnd.isLeftOver(endsAt: nil, hasActiveTrip: false, at: now))
    }
}
