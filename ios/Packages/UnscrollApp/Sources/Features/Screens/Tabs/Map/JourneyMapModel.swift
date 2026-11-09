import Core
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class JourneyMapModel {
    public private(set) var progress: JourneyProgress?
    public let journey = Journey.tokyoToKyoto

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let now: @MainActor () -> Date

    public init(
        database: AppDatabase,
        now: @escaping @MainActor () -> Date = { .now }
    ) {
        self.database = database
        self.now = now

        refresh()
    }
}

public extension JourneyMapModel {
    var kilometers: Int {
        min(progress?.kilometers ?? 0, journey.totalKilometers)
    }

    var nextLandmark: Landmark? {
        journey.nextLandmark(after: kilometers)
    }

    var kilometersToNext: Int? {
        nextLandmark.map { $0.kilometer - kilometers }
    }

    var remainingKilometers: Int {
        max(0, journey.totalKilometers - kilometers)
    }

    var progressRatio: Double {
        guard journey.totalKilometers > 0 else {
            return 0
        }

        let ratio = Double(kilometers) / Double(journey.totalKilometers)
        return min(1, max(0, ratio))
    }

    func isReached(_ landmark: Landmark) -> Bool {
        landmark.kilometer <= kilometers
    }

    func refresh() {
        progress = try? database.journeyProgress(at: now())
    }
}
