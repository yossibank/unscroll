public struct Landmark: Hashable, Sendable {
    public let name: String
    public let kilometer: Int
    public let artKey: String
    public let souvenir: String?

    public init(
        name: String,
        kilometer: Int,
        artKey: String,
        souvenir: String? = nil
    ) {
        self.name = name
        self.kilometer = kilometer
        self.artKey = artKey
        self.souvenir = souvenir
    }
}

public extension Landmark {
    static func named(_ name: String) -> Landmark? {
        Journey.all.lazy.flatMap(\.landmarks).first { $0.name == name }
    }
}
