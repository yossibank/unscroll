import Core
import Foundation
import Observation
import Store

@MainActor
@Observable
public final class CompanionPickerModel {
    public private(set) var species: Companion.Species
    public private(set) var coat: Companion.Coat
    public private(set) var name: String

    @ObservationIgnored private var isNameEdited: Bool
    @ObservationIgnored private let database: AppDatabase

    public init(database: AppDatabase) {
        let current = try? database.companion()
        let species = current?.species ?? .shiba

        self.species = species
        self.coat = current?.coat ?? .black
        self.name = current?.name ?? species.defaultName
        self.isNameEdited = current != nil
        self.database = database
    }
}

public extension CompanionPickerModel {
    var draft: Companion? {
        Companion(species: species, coat: coat, name: name)
    }

    var preview: Companion? {
        draft ?? Companion(species: species, coat: coat, name: species.defaultName)
    }

    var isNameTooLong: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count > Companion.nameLimit
    }

    var shownName: String {
        draft?.name ?? species.defaultName
    }

    func select(_ species: Companion.Species) {
        guard species != self.species else {
            return
        }

        self.species = species
        coat = species.coats[0]

        if !isNameEdited {
            name = species.defaultName
        }
    }

    func select(_ coat: Companion.Coat) {
        self.coat = coat
    }

    func rename(_ name: String) {
        self.name = name
        isNameEdited = true
    }

    func save() -> Bool {
        guard let draft else {
            return false
        }

        do {
            try database.saveCompanion(draft)
            return true
        } catch {
            EventLog.append("相棒：保存できない（\(error.localizedDescription)）")
            return false
        }
    }
}
