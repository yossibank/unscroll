import Foundation

public struct ShieldLetter: Hashable, Sendable {
    public let title: String
    public let body: String
    public let primaryButton: String

    public init(
        companionName: String?,
        remainingMinutes: Int?
    ) {
        let lead = remainingMinutes.map { "旅はあと \($0) 分" } ?? "旅の途中だよ"

        self.title = companionName.map { "\($0)より" } ?? "旅先からの手紙"
        self.body = "\(lead)\nスマホはお休みしててね。"
        self.primaryButton = "旅に戻る"
    }
}
