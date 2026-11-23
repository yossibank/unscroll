import Core
import Foundation
import Testing

struct EventLogTests {
    private static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    @Test
    func putsNewestLineFirst() throws {
        let defaults = try makeDefaults()

        EventLog.append("1 つ目", at: Self.fixedDate, defaults: defaults)
        EventLog.append("2 つ目", at: Self.fixedDate, defaults: defaults)

        let lines = EventLog.lines(defaults: defaults)
        #expect(lines.count == 2)
        #expect(lines[0].hasSuffix("2 つ目"))
        #expect(lines[1].hasSuffix("1 つ目"))
    }

    @Test
    func keepsOnlyTheLimit() throws {
        let defaults = try makeDefaults()

        for index in 0...EventLog.limit {
            EventLog.append("\(index)", at: Self.fixedDate, defaults: defaults)
        }

        let lines = EventLog.lines(defaults: defaults)
        #expect(lines.count == EventLog.limit)
        #expect(lines[0].hasSuffix(" \(EventLog.limit)"))
    }

    @Test
    func clearsLines() throws {
        let defaults = try makeDefaults()
        EventLog.append("消す", at: Self.fixedDate, defaults: defaults)

        EventLog.clear(defaults: defaults)

        #expect(EventLog.lines(defaults: defaults).isEmpty)
    }

    @Test
    func returnsEmptyWithoutDefaults() {
        #expect(EventLog.lines(defaults: nil).isEmpty)
    }
}

private extension EventLogTests {
    func makeDefaults() throws -> UserDefaults {
        try #require(UserDefaults(suiteName: "EventLogTests-\(UUID().uuidString)"))
    }
}
