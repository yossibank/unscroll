import SwiftUI

public struct RoomBackdrop: View {
    public init() {}

    public var body: some View {
        Image("room_back", bundle: .module)
            .interpolation(.none)
            .resizable()
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
            .accessibilityHidden(true)
    }
}

public extension RoomBackdrop {
    static let width: CGFloat = 180
    static let height: CGFloat = 140
    static let aspectRatio: CGFloat = width / height
}
