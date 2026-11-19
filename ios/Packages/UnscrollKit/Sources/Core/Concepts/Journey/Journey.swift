import Foundation

public struct Journey: Hashable, Sendable {
    public let id: String
    public let name: String
    public let landmarks: [Landmark]

    public init(
        id: String,
        name: String,
        landmarks: [Landmark]
    ) {
        self.id = id
        self.name = name
        self.landmarks = landmarks
    }
}

public extension Journey {
    static let all: [Journey] = [
        .tokyoSightseeing,
        .tokyoToKyoto,
        .tohokuShinkansen,
        .okinawa,
        .worldHeritage,
        .osakaHakata,
        .hokkaido,
        .shikoku
    ]

    var totalKilometers: Int {
        landmarks.last?.kilometer ?? 0
    }

    static func with(id: String) -> Journey? {
        all.first { $0.id == id }
    }

    func nextLandmark(after kilometers: Int) -> Landmark? {
        landmarks.first { $0.kilometer > kilometers }
    }

    func landmarkReached(
        from start: Int,
        to end: Int
    ) -> Landmark? {
        landmarks.last { $0.kilometer > start && $0.kilometer <= end }
    }

    func arrivals(
        on trip: Trip,
        startingAt kilometers: Int,
        at now: Date
    ) -> [Arrival] {
        let end = kilometers + trip.kilometers(at: now)

        return landmarks
            .filter { $0.kilometer > kilometers && $0.kilometer <= end }
            .sorted { $0.kilometer < $1.kilometer }
            .map { landmark in
                let minutes = (landmark.kilometer - kilometers) / Trip.kilometersPerMinute

                return Arrival(
                    landmark: landmark,
                    tripID: trip.id,
                    arrivedAt: trip.startedAt.addingTimeInterval(TimeInterval(minutes * 60))
                )
            }
    }
}
