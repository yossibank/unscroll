import Core
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class PostcardAlbumModel {
    public private(set) var arrivals: [Arrival] = []
    public private(set) var kilometers = 0
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

public extension PostcardAlbumModel {
    struct Entry: Hashable, Sendable {
        public let landmark: Landmark
        public let arrival: Arrival?
        public let remainingKilometers: Int

        public var isCollected: Bool {
            arrival != nil
        }
    }

    var entries: [Entry] {
        journey.landmarks.dropFirst().map { landmark in
            Entry(
                landmark: landmark,
                arrival: arrival(at: landmark),
                remainingKilometers: max(0, landmark.kilometer - kilometers)
            )
        }
    }

    var collectedCount: Int {
        entries.count(where: \.isCollected)
    }

    var totalCount: Int {
        entries.count
    }

    func arrival(at landmark: Landmark) -> Arrival? {
        arrivals.first { $0.landmark.name == landmark.name }
    }

    func setDecorated(
        _ isDecorated: Bool,
        landmark: Landmark
    ) {
        do {
            try database.setDecorated(isDecorated, landmark: landmark, at: now())
        } catch {
            EventLog.append("絵はがき：飾れない（\(error.localizedDescription)）")
        }

        refresh()
    }

    func refresh() {
        let date = now()

        do {
            try database.recordArrivals(on: journey, at: date)
        } catch {
            EventLog.append("名所：着いた記録を保存できない（\(error.localizedDescription)）")
        }

        let progress = try? database.journeyProgress(at: date)
        kilometers = min(progress?.kilometers ?? 0, journey.totalKilometers)
        arrivals = (try? database.arrivals()) ?? []
    }
}
