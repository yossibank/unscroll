import Foundation

public struct Arrival: Hashable, Sendable {
    public let landmark: Landmark
    public let tripID: Trip.ID
    public let arrivedAt: Date

    public init(
        landmark: Landmark,
        tripID: Trip.ID,
        arrivedAt: Date
    ) {
        self.landmark = landmark
        self.tripID = tripID
        self.arrivedAt = arrivedAt
    }
}
