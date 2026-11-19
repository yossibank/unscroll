import Foundation

public struct FocusEndFile: Sendable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }
}

public extension FocusEndFile {
    struct Entry: Codable, Equatable, Sendable {
        public let endsAt: Date
        public let activity: String

        public init(
            endsAt: Date,
            activity: String
        ) {
            self.endsAt = endsAt
            self.activity = activity
        }
    }

    static var shared: FocusEndFile? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: ScreenTimeShared.appGroup)
            .map { FocusEndFile(url: $0.appending(path: "focus-ends-at")) }
    }

    func read() -> Entry? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return try? JSONDecoder().decode(Entry.self, from: data)
    }

    func write(_ entry: Entry) throws {
        let data = try JSONEncoder().encode(entry)
        try data.write(to: url, options: .atomic)
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
