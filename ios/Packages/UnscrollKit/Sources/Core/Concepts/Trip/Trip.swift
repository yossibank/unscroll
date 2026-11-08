import Foundation

public struct Trip: Hashable, Sendable {
    public typealias ID = Identifier<Trip>

    public let id: ID
    public let startedAt: Date
    public let plannedMinutes: Int
    public var endedAt: Date?

    public init(
        id: ID = ID(),
        startedAt: Date,
        plannedMinutes: Int,
        endedAt: Date? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.plannedMinutes = plannedMinutes
        self.endedAt = endedAt
    }
}

public extension Trip {
    static let kilometersPerMinute = 1

    var plannedEnd: Date {
        startedAt.addingTimeInterval(TimeInterval(plannedMinutes * 60))
    }

    func isActive(at now: Date) -> Bool {
        endedAt == nil && now < plannedEnd
    }

    func focusedMinutes(at now: Date) -> Int {
        let end = min(now, endedAt ?? now, plannedEnd)
        let minutes = Int(end.timeIntervalSince(startedAt) / 60)

        return min(max(minutes, 0), plannedMinutes)
    }

    func kilometers(at now: Date) -> Int {
        focusedMinutes(at: now) * Self.kilometersPerMinute
    }
}

extension Trip: Identifiable {}
