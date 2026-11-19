import Foundation

public struct Trip: Hashable, Sendable {
    public typealias ID = Identifier<Trip>

    public let id: ID
    public let startedAt: Date
    public let plannedMinutes: Int
    public let isPractice: Bool
    public var endedAt: Date?

    public init(
        id: ID = ID(),
        startedAt: Date,
        plannedMinutes: Int,
        isPractice: Bool = false,
        endedAt: Date? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.plannedMinutes = plannedMinutes
        self.isPractice = isPractice
        self.endedAt = endedAt
    }
}

public extension Trip {
    static let kilometersPerMinute = 1
    static let practiceSeconds: TimeInterval = 10

    var plannedEnd: Date {
        let seconds = isPractice ? Self.practiceSeconds : TimeInterval(plannedMinutes * 60)
        return startedAt.addingTimeInterval(seconds)
    }

    var isCompleted: Bool {
        guard let endedAt else {
            return true
        }

        return endedAt >= plannedEnd
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

    func remainingMinutes(at now: Date) -> Int? {
        guard isActive(at: now) else {
            return nil
        }

        let seconds = plannedEnd.timeIntervalSince(now)
        return Int((seconds / 60).rounded(.up))
    }
}

extension Trip: Identifiable {}
