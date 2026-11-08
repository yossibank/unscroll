public struct Landmark: Hashable, Sendable {
    public let name: String
    public let kilometer: Int

    public init(
        name: String,
        kilometer: Int
    ) {
        self.name = name
        self.kilometer = kilometer
    }
}
