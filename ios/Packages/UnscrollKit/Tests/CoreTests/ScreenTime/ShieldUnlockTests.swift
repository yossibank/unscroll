import Core
import Foundation
import Testing

struct ShieldUnlockTests {
    @Test
    func opensAtOnceWhenGentle() {
        let now = Date(timeIntervalSince1970: 1000)
        #expect(ShieldUnlock(strictness: .gentle, pressedAt: nil, now: now) == .open)
    }

    @Test
    func staysClosedWhenStrict() {
        let pressedAt = Date(timeIntervalSince1970: 1000)
        let now = pressedAt.addingTimeInterval(ShieldUnlock.waitSeconds)
        #expect(ShieldUnlock(strictness: .strict, pressedAt: pressedAt, now: now) == .closed)
    }

    @Test
    func startsWaitingOnFirstPress() {
        let now = Date(timeIntervalSince1970: 1000)
        #expect(ShieldUnlock(strictness: .normal, pressedAt: nil, now: now) == .startWaiting)
    }

    @Test
    func keepsWaitingBeforeTenSeconds() {
        let pressedAt = Date(timeIntervalSince1970: 1000)
        let now = pressedAt.addingTimeInterval(ShieldUnlock.waitSeconds - 0.1)
        #expect(ShieldUnlock(strictness: .normal, pressedAt: pressedAt, now: now) == .keepWaiting)
    }

    @Test
    func opensAtTenSeconds() {
        let pressedAt = Date(timeIntervalSince1970: 1000)
        let now = pressedAt.addingTimeInterval(ShieldUnlock.waitSeconds)
        #expect(ShieldUnlock(strictness: .normal, pressedAt: pressedAt, now: now) == .open)
    }

    @Test
    func opensUntilPressGoesStale() {
        let pressedAt = Date(timeIntervalSince1970: 1000)
        let now = pressedAt.addingTimeInterval(ShieldUnlock.staleSeconds)
        #expect(ShieldUnlock(strictness: .normal, pressedAt: pressedAt, now: now) == .open)
    }

    @Test
    func startsOverWhenPressIsStale() {
        let pressedAt = Date(timeIntervalSince1970: 1000)
        let now = pressedAt.addingTimeInterval(ShieldUnlock.staleSeconds + 0.1)
        #expect(ShieldUnlock(strictness: .normal, pressedAt: pressedAt, now: now) == .startWaiting)
    }

    @Test
    func startsOverWhenPressIsInFuture() {
        let pressedAt = Date(timeIntervalSince1970: 1000)
        let now = pressedAt.addingTimeInterval(-1)
        #expect(ShieldUnlock(strictness: .normal, pressedAt: pressedAt, now: now) == .startWaiting)
    }
}
