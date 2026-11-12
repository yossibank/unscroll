import Foundation

public struct Companion: Hashable, Sendable {
    public let species: Species
    public let coat: Coat
    public let name: String

    public init?(
        species: Species,
        coat: Coat,
        name: String
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            species.coats.contains(coat),
            !trimmed.isEmpty,
            trimmed.count <= Self.nameLimit
        else {
            return nil
        }

        self.species = species
        self.coat = coat
        self.name = trimmed
    }
}

public extension Companion {
    static let nameLimit = 8

    var kindLabel: String {
        "\(species.label(of: coat))の\(species.label)"
    }

    func artName(_ pose: Pose) -> String {
        "\(species.rawValue)_\(coat.rawValue)_\(pose.rawValue)"
    }
}
