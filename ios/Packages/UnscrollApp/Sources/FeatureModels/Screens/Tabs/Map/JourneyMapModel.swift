import Core
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class JourneyMapModel {
    public private(set) var progress: JourneyProgress?
    public private(set) var companion: Companion?
    public private(set) var journey = Journey.tokyoSightseeing

    @ObservationIgnored private let parts: ScreenParts

    public init(parts: ScreenParts) {
        self.parts = parts

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

    var isOnTrip: Bool {
        progress?.activeTrip != nil
    }

    var progressRatio: Double {
        guard journey.totalKilometers > 0 else {
            return 0
        }

        let ratio = Double(kilometers) / Double(journey.totalKilometers)
        return min(1, max(0, ratio))
    }

    func makeJourneyPicker() -> JourneyPickerModel {
        JourneyPickerModel(parts: parts)
    }

    func refresh() {
        journey = (try? parts.database.currentJourney()) ?? .tokyoSightseeing
        progress = try? parts.database.journeyProgress(at: parts.clock.now)
        companion = try? parts.database.companion()
    }
}
