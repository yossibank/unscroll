import Foundation

public struct Arrival: Hashable, Sendable {
    public let landmark: Landmark
    public let tripID: Trip.ID
    public let arrivedAt: Date
    public var decoratedAt: Date?

    public init(
        landmark: Landmark,
        tripID: Trip.ID,
        arrivedAt: Date,
        decoratedAt: Date? = nil
    ) {
        self.landmark = landmark
        self.tripID = tripID
        self.arrivedAt = arrivedAt
        self.decoratedAt = decoratedAt
    }
}

public extension Arrival {
    var isDecorated: Bool {
        decoratedAt != nil
    }
}
