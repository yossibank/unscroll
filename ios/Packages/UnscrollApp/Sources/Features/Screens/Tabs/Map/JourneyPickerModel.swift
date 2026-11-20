import Core
import DesignSystem
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class JourneyPickerModel: Identifiable {
    public private(set) var journeys: [Journey]
    public private(set) var currentID: String
    public private(set) var isOnTrip = false
    public private(set) var kilometersByID: [String: Int] = [:]

    public var selectedID: String
    public var filter = Filter.open

    @ObservationIgnored private let database: AppDatabase
    @ObservationIgnored private let now: @MainActor () -> Date

    public init(
        database: AppDatabase,
        now: @escaping @MainActor () -> Date = { .now },
        isAvailable: (Journey) -> Bool = LandmarkArt.isAvailable(for:)
    ) {
        let current = (try? database.currentJourney()) ?? .tokyoSightseeing

        self.journeys = Journey.all.filter(isAvailable)
        self.currentID = current.id
        self.selectedID = current.id

        self.database = database
        self.now = now

        refresh()
    }
}

public extension JourneyPickerModel {
    enum Filter: CaseIterable, Sendable {
        case all
        case open
        case finished

        public var title: String {
            switch self {
            case .all: "すべて"
            case .open: "未完了"
            case .finished: "完了"
            }
        }
    }

    var shownJourneys: [Journey] {
        journeys.filter { matches($0, filter) }
    }

    var selectedJourney: Journey {
        Journey.with(id: selectedID) ?? .tokyoToKyoto
    }

    var canConfirm: Bool {
        !isOnTrip && selectedID != currentID
    }

    static func focusText(kilometers: Int) -> String {
        let minutes = kilometers / Trip.kilometersPerMinute

        guard minutes >= 60 else {
            return "約 \(minutes) 分"
        }

        return "約 \((minutes + 30) / 60) 時間"
    }

    func kilometers(of journey: Journey) -> Int {
        min(kilometersByID[journey.id] ?? 0, journey.totalKilometers)
    }

    func isCurrent(_ journey: Journey) -> Bool {
        journey.id == currentID
    }

    func isFinished(_ journey: Journey) -> Bool {
        kilometers(of: journey) >= journey.totalKilometers
    }

    func count(_ filter: Filter) -> Int {
        journeys.count { matches($0, filter) }
    }

    func refresh() {
        let date = now()
        let current = try? database.journeyProgress(journeyID: currentID, at: date)

        isOnTrip = current?.activeTrip != nil
        kilometersByID = Dictionary(
            uniqueKeysWithValues: journeys.map { journey in
                let progress = try? database.journeyProgress(journeyID: journey.id, at: date)
                return (journey.id, progress?.kilometers ?? 0)
            }
        )
    }

    func confirm() -> Bool {
        guard canConfirm else {
            return false
        }

        guard (try? database.selectJourney(selectedID, at: now())) == true else {
            return false
        }

        currentID = selectedID
        return true
    }
}

private extension JourneyPickerModel {
    func matches(
        _ journey: Journey,
        _ filter: Filter
    ) -> Bool {
        switch filter {
        case .all: true
        case .open: !isFinished(journey)
        case .finished: isFinished(journey)
        }
    }
}
