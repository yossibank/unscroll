import Foundation

public struct ShieldLetter: Hashable, Sendable {
    public let title: String
    public let body: String

    public init(
        companionName: String?,
        journey: Journey,
        kilometers: Int?
    ) {
        let name = companionName ?? "相棒"
        let next = kilometers.flatMap { journey.nextLandmark(after: $0) }

        self.title = "\(name)から手紙が届いたよ"

        if let kilometers,
           let next {
            let remaining = next.kilometer - kilometers
            self.body = "まだ帰らないよ。\(next.name)まで、あと \(remaining) km。いっしょに行こう。"
        } else {
            self.body = "まだ帰らないよ。いっしょに行こう。"
        }
    }
}
