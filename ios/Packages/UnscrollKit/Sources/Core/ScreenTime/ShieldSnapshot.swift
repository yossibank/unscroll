import Foundation

public struct ShieldSnapshot: Codable, Hashable, Sendable {
    public let species: String?
    public let coat: String?
    public let name: String?
    public let journeyID: String
    public let finishedKilometers: Int
    public let tripStartedAt: Date
    public let tripPlannedMinutes: Int

    public init?(
        companion: Companion?,
        journey: Journey,
        totalKilometers: Int,
        activeTrip: Trip?,
        at now: Date
    ) {
        guard let activeTrip else {
            return nil
        }

        self.species = companion?.species.rawValue
        self.coat = companion?.coat.rawValue
        self.name = companion?.name
        self.journeyID = journey.id
        self.finishedKilometers = max(totalKilometers - activeTrip.kilometers(at: now), 0)
        self.tripStartedAt = activeTrip.startedAt
        self.tripPlannedMinutes = activeTrip.plannedMinutes
    }
}

public extension ShieldSnapshot {
    static let key = "shield.snapshot"

    var companion: Companion? {
        guard
            let species = species.flatMap(Companion.Species.init(rawValue:)),
            let coat = coat.flatMap(Companion.Coat.init(rawValue:)),
            let name
        else {
            return nil
        }

        return Companion(
            species: species,
            coat: coat,
            name: name
        )
    }

    var journey: Journey {
        Journey.with(id: journeyID) ?? .tokyoToKyoto
    }

    var trip: Trip {
        Trip(
            startedAt: tripStartedAt,
            plannedMinutes: tripPlannedMinutes
        )
    }

    static func load(
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) -> ShieldSnapshot? {
        guard let data = defaults?.data(forKey: key) else {
            return nil
        }

        return try? JSONDecoder().decode(ShieldSnapshot.self, from: data)
    }

    static func clear(
        defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)
    ) {
        defaults?.removeObject(forKey: key)
    }

    func kilometers(at now: Date) -> Int {
        finishedKilometers + trip.kilometers(at: now)
    }

    func letter(at now: Date) -> ShieldLetter {
        ShieldLetter(
            companionName: companion?.name,
            remainingMinutes: trip.remainingMinutes(at: now)
        )
    }

    func save(defaults: UserDefaults? = UserDefaults(suiteName: ScreenTimeShared.appGroup)) {
        guard let data = try? JSONEncoder().encode(self) else {
            return
        }

        defaults?.set(data, forKey: Self.key)
    }
}
