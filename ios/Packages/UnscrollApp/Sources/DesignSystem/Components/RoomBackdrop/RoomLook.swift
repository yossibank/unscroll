import SwiftUI

public struct RoomLook: Equatable, Sendable {
    public var wall: Wall
    public var floor: Floor

    public init(
        wall: Wall = .plaster,
        floor: Floor = .wood
    ) {
        self.wall = wall
        self.floor = floor
    }
}

public extension RoomLook {
    enum Wall: String, CaseIterable, Identifiable, Sendable {
        case plaster
        case dots
        case stripe
        case stars

        public var id: String {
            rawValue
        }

        public var name: String {
            switch self {
            case .plaster: "しっくい"
            case .dots: "水玉"
            case .stripe: "縞"
            case .stars: "星"
            }
        }

        var artName: String {
            "room_wall_\(rawValue)"
        }

        public var swatch: some View {
            RoomLook.swatch(artName, crop: CGRect(x: 90, y: 0, width: 90, height: 60))
        }
    }

    enum Floor: String, CaseIterable, Identifiable, Sendable {
        case wood
        case tatami
        case tile

        public var id: String {
            rawValue
        }

        public var name: String {
            switch self {
            case .wood: "木目"
            case .tatami: "畳"
            case .tile: "タイル"
            }
        }

        var artName: String {
            "room_floor_\(rawValue)"
        }

        public var swatch: some View {
            RoomLook.swatch(artName, crop: CGRect(x: 0, y: 100, width: 180, height: 40))
        }
    }
}

private extension RoomLook {
    static func swatch(
        _ name: String,
        crop: CGRect
    ) -> some View {
        GeometryReader { proxy in
            let scale = max(proxy.size.width / crop.width, proxy.size.height / crop.height)

            Image(name, bundle: .module)
                .interpolation(.none)
                .resizable()
                .frame(width: RoomBackdrop.width * scale, height: RoomBackdrop.height * scale)
                .offset(x: -crop.minX * scale, y: -crop.minY * scale)
        }
        .clipped()
        .accessibilityHidden(true)
    }
}
