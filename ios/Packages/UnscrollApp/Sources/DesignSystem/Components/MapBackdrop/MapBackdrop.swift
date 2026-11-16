import SwiftUI

public struct MapBackdrop: View {
    public init() {}

    public var body: some View {
        Image("map_back", bundle: .module)
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
