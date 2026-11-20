import Core
import Testing

struct ScreenTimeSharedTests {
    @Test
    func namesUsageEventByMinutes() {
        #expect(ScreenTimeShared.usageEventName(minutes: 5) == "usage.5m")
    }

    @Test
    func namesTheTripWatchByTrip() {
        #expect(ScreenTimeShared.focusActivityName(tripID: "12") == "focus.12")
    }

    @Test
    func findsTheTripWatchByItsName() {
        let name = ScreenTimeShared.focusActivityName(tripID: "12")
        #expect(ScreenTimeShared.isFocusActivity(name))
    }

    @Test
    func tellsOtherWatchesApart() {
        #expect(!ScreenTimeShared.isFocusActivity(ScreenTimeShared.unlockActivityName))
        #expect(!ScreenTimeShared.isFocusActivity(ScreenTimeShared.usageActivityName))
    }
}
