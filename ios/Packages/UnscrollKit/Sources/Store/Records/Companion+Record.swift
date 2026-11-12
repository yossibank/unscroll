import Core
import GRDB

extension Companion: FetchableRecord, PersistableRecord {
    public enum Columns: String, ColumnExpression {
        case id
        case species
        case coat
        case name
    }

    static let rowID = 1

    public static var databaseTableName: String {
        "companion"
    }

    public init(row: Row) throws {
        let species: String = row[Columns.species]
        let coat: String = row[Columns.coat]
        let name: String = row[Columns.name]

        guard
            let species = Species(rawValue: species),
            let coat = Coat(rawValue: coat),
            let companion = Companion(species: species, coat: coat, name: name)
        else {
            throw DatabaseError(message: "Invalid companion: \(species) \(coat) \(name)")
        }

        self = companion
    }

    public func encode(to container: inout PersistenceContainer) throws {
        container[Columns.id] = Self.rowID
        container[Columns.species] = species.rawValue
        container[Columns.coat] = coat.rawValue
        container[Columns.name] = name
    }
}
