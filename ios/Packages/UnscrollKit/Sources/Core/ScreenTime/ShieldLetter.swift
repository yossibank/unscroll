import Foundation

public struct ShieldLetter: Hashable, Sendable {
    public let title: String
    public let body: String
    public let primaryButton: String

    public init(
        companionName: String?,
        journey: Journey,
        kilometers: Int?,
        remainingMinutes: Int?
    ) {
        var lines: [String] = []

        if let kilometers,
           let here = journey.landmarks.last(where: { $0.kilometer <= kilometers }) {
            lines.append("いま\(here.name)の近くを歩いてるよ。")
        }

        if let kilometers,
           let next = journey.nextLandmark(after: kilometers) {
            let distance = (next.kilometer - kilometers).formatted()
            lines.append("あと \(distance) km で\(next.name)に着くんだ。")
        }

        if let remainingMinutes {
            lines.append("旅はあと \(remainingMinutes) 分。スマホはお休みしててね。")
        }

        if lines.isEmpty {
            lines.append("旅の途中だよ。スマホはお休みしててね。")
        }

        self.title = companionName.map { "\($0)より" } ?? "旅先からの手紙"
        self.body = lines.joined(separator: "\n")
        self.primaryButton = "旅に戻る"
    }
}
