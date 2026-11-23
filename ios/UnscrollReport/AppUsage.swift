import Foundation
import ManagedSettings

struct AppUsage: Identifiable, @unchecked Sendable {
    let id: String
    let name: String
    let token: ApplicationToken?
    let duration: TimeInterval
    let pickups: Int
    let notifications: Int
}
