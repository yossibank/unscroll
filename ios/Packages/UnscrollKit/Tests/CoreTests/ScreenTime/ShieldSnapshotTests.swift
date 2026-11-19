import Core
import Foundation
import Testing

struct ShieldSnapshotTests {
    @Test
    func isNilWithoutActiveTrip() {
        let snapshot = ShieldSnapshot(
            companion: .starter,
            journey: .tokyoToKyoto,
            totalKilometers: 40,
            activeTrip: nil,
            at: Self.start
        )

        #expect(snapshot == nil)
    }

    @Test
    func addsTripDistanceToFinishedDistance() throws {
        let trip = Trip(startedAt: Self.start, plannedMinutes: 60)
        let saved = Self.start.addingTimeInterval(10 * 60)
        let later = Self.start.addingTimeInterval(30 * 60)

        let snapshot = try #require(
            ShieldSnapshot(
                companion: .starter,
                journey: .tokyoToKyoto,
                totalKilometers: 50,
                activeTrip: trip,
                at: saved
            )
        )

        #expect(snapshot.finishedKilometers == 40)
        #expect(snapshot.kilometers(at: later) == 70)
        #expect(snapshot.trip.remainingMinutes(at: later) == 30)
    }

    @Test
    func readsBackCompanionAndLetter() throws {
        let defaults = try #require(UserDefaults(suiteName: "ShieldSnapshotTests.\(UUID())"))
        let trip = Trip(startedAt: Self.start, plannedMinutes: 60)
        let companion = try #require(Companion.starter)
        let later = Self.start.addingTimeInterval(20 * 60)

        let snapshot = ShieldSnapshot(
            companion: companion,
            journey: .tokyoToKyoto,
            totalKilometers: 0,
            activeTrip: trip,
            at: Self.start
        )

        snapshot?.save(defaults: defaults)
        let loaded = try #require(ShieldSnapshot.load(defaults: defaults))

        #expect(loaded.companion == companion)
        #expect(loaded.letter(at: later).title == "\(companion.name)より")
        #expect(loaded.letter(at: later).body.hasPrefix("旅はあと 40 分\n"))
    }

    @Test
    func clearRemovesSnapshot() throws {
        let defaults = try #require(UserDefaults(suiteName: "ShieldSnapshotTests.\(UUID())"))
        let trip = Trip(startedAt: Self.start, plannedMinutes: 60)

        let snapshot = ShieldSnapshot(
            companion: nil,
            journey: .tokyoToKyoto,
            totalKilometers: 0,
            activeTrip: trip,
            at: Self.start
        )

        snapshot?.save(defaults: defaults)
        ShieldSnapshot.clear(defaults: defaults)

        #expect(ShieldSnapshot.load(defaults: defaults) == nil)
    }
}

extension ShieldSnapshotTests {
    static let start = Date(timeIntervalSince1970: 1_800_000_000)
}
