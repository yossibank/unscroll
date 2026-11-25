import FamilyControls
import Foundation

public struct BlockedAppSet: Codable, Equatable, Identifiable {
    public let id: UUID

    public internal(set) var name: String
    public internal(set) var selection: FamilyActivitySelection
}
