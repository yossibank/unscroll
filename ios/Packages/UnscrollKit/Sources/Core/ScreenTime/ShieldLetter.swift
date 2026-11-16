import Foundation

public struct ShieldLetter: Hashable, Sendable {
    public let title: String
    public let body: String

    public init(
        companionName: String?,
        journey: Journey,
        kilometers: Int?,
        remainingMinutes: Int?
    ) {
        let name = companionName ?? "相棒"
        let next = kilometers.flatMap { journey.nextLandmark(after: $0) }
        var lines = ["まだ帰らないよ。"]

        if let kilometers,
           let next {
            lines.append("\(next.name)まで、あと \(next.kilometer - kilometers) km。")
        }

        if let remainingMinutes {
            lines.append("旅はあと \(remainingMinutes) 分。")
        }

        lines.append("いっしょに行こう。")

        self.title = "\(name)から手紙が届いたよ"
        self.body = lines.joined()
    }
}
