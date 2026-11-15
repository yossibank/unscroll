import DesignSystem
import Foundation
import Testing

struct DayPeriodTests {
    @Test(arguments: [
        (0, DayPeriod.night),
        (4, .night),
        (5, .morning),
        (8, .morning),
        (9, .day),
        (15, .day),
        (16, .evening),
        (18, .evening),
        (19, .night)
    ])
    func followsHour(
        hour: Int,
        period: DayPeriod
    ) throws {
        let date = try Self.date(hour: hour)
        #expect(DayPeriod(date: date, calendar: Self.calendar) == period)
    }
}

private extension DayPeriodTests {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    static func date(hour: Int) throws -> Date {
        let components = DateComponents(year: 2026, month: 4, day: 1, hour: hour)
        return try #require(calendar.date(from: components))
    }
}
