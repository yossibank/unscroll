import Foundation

public struct FocusEndFile: Sendable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}

public extension FocusEndFile {
    static var shared: FocusEndFile? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: ScreenTimeShared.appGroup)
            .map { FocusEndFile(url: $0.appending(path: "focus-ends-at")) }
    }

    func read() -> Date? {
        guard
            let data = try? Data(contentsOf: url),
            let seconds = TimeInterval(String(decoding: data, as: UTF8.self))
        else {
            return nil
        }

        return Date(timeIntervalSince1970: seconds)
    }

    func write(_ date: Date) throws {
        let text = String(date.timeIntervalSince1970)
        try Data(text.utf8).write(to: url, options: .atomic)
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
