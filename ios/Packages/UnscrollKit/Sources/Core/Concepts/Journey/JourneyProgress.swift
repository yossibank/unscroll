public struct JourneyProgress: Hashable, Sendable {
    public let activeTrip: Trip?
    public let lastTrip: Trip?
    public let kilometers: Int

    public init(
        activeTrip: Trip?,
        lastTrip: Trip?,
        kilometers: Int
    ) {
        self.activeTrip = activeTrip
        self.lastTrip = lastTrip
        self.kilometers = kilometers
    }
}
