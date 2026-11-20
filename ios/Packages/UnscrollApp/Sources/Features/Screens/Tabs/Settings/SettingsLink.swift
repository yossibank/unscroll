import Foundation

enum SettingsLink {
    static let appStoreID = "6837062708"
    static let contactForm = "https://docs.google.com/forms/d/e/1FAIpQLSf7lGzXt7Z7JFLs400k18FfjDDf4-kqryKd4AToXRMQmywmYA/viewform"
    static let modelEntry = "entry.650948704"
    static let systemEntry = "entry.1952152946"
    static let appEntry = "entry.942237148"

    static let review =
        URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    static var modelIdentifier: String {
        if let simulated = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulated
        }

        var system = utsname()
        uname(&system)

        return withUnsafeBytes(of: system.machine) { bytes in
            String(decoding: bytes.prefix { $0 != 0 }, as: UTF8.self)
        }
    }

    static var systemVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let base = "\(version.majorVersion).\(version.minorVersion)"
        return version.patchVersion > 0 ? "\(base).\(version.patchVersion)" : base
    }

    static func contact(
        model: String = modelIdentifier,
        system: String = systemVersion,
        app: String = appVersion
    ) -> URL? {
        var components = URLComponents(string: contactForm)

        components?.queryItems = [
            URLQueryItem(name: "usp", value: "pp_url"),
            URLQueryItem(name: modelEntry, value: model),
            URLQueryItem(name: systemEntry, value: system),
            URLQueryItem(name: appEntry, value: app)
        ]

        return components?.url
    }
}
