import FamilyControls
import Foundation

struct BlockedAppSet: Codable, Equatable, Identifiable {
    let id: UUID

    var name: String
    var selection: FamilyActivitySelection
}
