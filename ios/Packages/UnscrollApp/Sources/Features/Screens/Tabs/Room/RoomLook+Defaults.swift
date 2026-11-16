import DesignSystem
import Foundation

extension RoomLook {
    init(defaults: UserDefaults) {
        let wall = defaults.string(forKey: Self.wallKey).flatMap(Wall.init(rawValue:))
        let floor = defaults.string(forKey: Self.floorKey).flatMap(Floor.init(rawValue:))

        self.init(
            wall: wall ?? .plaster,
            floor: floor ?? .wood
        )
    }

    func save(to defaults: UserDefaults) {
        defaults.set(wall.rawValue, forKey: Self.wallKey)
        defaults.set(floor.rawValue, forKey: Self.floorKey)
    }
}

private extension RoomLook {
    static let wallKey = "room.wall"
    static let floorKey = "room.floor"
}
