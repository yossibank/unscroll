import Core
import Testing

struct ScreenTimeSharedTests {
    @Test
    func namesUsageEventByMinutes() {
        #expect(ScreenTimeShared.usageEventName(minutes: 5) == "usage.5m")
    }
}
