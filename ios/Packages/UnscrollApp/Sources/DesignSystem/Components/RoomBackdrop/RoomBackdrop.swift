import SwiftUI

public struct RoomBackdrop: View {
    private let look: RoomLook

    public init(look: RoomLook) {
        self.look = look
    }

    public var body: some View {
        ZStack {
            layer(look.wall.artName)
            layer(look.floor.artName)
            layer("room_back")
        }
        .aspectRatio(Self.aspectRatio, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

public extension RoomBackdrop {
    static let width: CGFloat = 180
    static let height: CGFloat = 140
    static let aspectRatio: CGFloat = width / height
}

private extension RoomBackdrop {
    func layer(_ name: String) -> some View {
        Image(name, bundle: .module)
            .interpolation(.none)
            .resizable()
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
    }
}
