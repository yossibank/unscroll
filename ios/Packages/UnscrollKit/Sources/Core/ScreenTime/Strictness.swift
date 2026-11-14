import Foundation

public enum Strictness: String, CaseIterable, Sendable {
    case gentle
    case normal
    case strict

    public static let settingKey = "strictness"
    public static let tripKey = "focus.strictness"

    public static func saved(
        forKey key: String,
        in defaults: UserDefaults?
    ) -> Strictness {
        defaults?.string(forKey: key).flatMap(Strictness.init(rawValue:)) ?? .normal
    }
}
