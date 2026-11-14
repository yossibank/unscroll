import Core
import Foundation
import Testing

struct StrictnessTests {
    @Test
    func readsSavedValue() throws {
        let defaults = try #require(UserDefaults(suiteName: "StrictnessTests.\(UUID())"))

        defaults.set(Strictness.strict.rawValue, forKey: Strictness.settingKey)

        #expect(Strictness.saved(forKey: Strictness.settingKey, in: defaults) == .strict)
    }

    @Test
    func fallsBackToNormal() throws {
        let defaults = try #require(UserDefaults(suiteName: "StrictnessTests.\(UUID())"))

        defaults.set("unknown", forKey: Strictness.settingKey)

        #expect(Strictness.saved(forKey: Strictness.settingKey, in: defaults) == .normal)
        #expect(Strictness.saved(forKey: Strictness.tripKey, in: defaults) == .normal)
    }
}
