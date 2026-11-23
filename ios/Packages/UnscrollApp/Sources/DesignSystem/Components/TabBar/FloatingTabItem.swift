import SwiftUI

public struct FloatingTabItem<Tab: Hashable>: Identifiable {
    public let tab: Tab
    public let title: String
    public let systemImage: String
    public let tint: Color

    public init(
        tab: Tab,
        title: String,
        systemImage: String,
        tint: Color
    ) {
        self.tab = tab
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }
}

public extension FloatingTabItem {
    var id: Tab {
        tab
    }
}
