import SwiftUI

public struct MapBackdrop: View {
    private let name: String

    public init(name: String) {
        self.name = name
    }

    public var body: some View {
        Image(name, bundle: .module)
            .interpolation(.none)
            .resizable()
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
            .accessibilityHidden(true)
    }
}

public extension MapBackdrop {
    static let width: CGFloat = 228
    static let height: CGFloat = 150
    static let aspectRatio: CGFloat = width / height
}
