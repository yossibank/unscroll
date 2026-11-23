import Foundation

struct CategoryUsage: Identifiable, Sendable {
    static let otherName = "ほか"

    let id: String
    let name: String
    let duration: TimeInterval
}
