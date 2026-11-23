public extension Landmark {
    var artName: String {
        "landmark_\(artKey)"
    }

    var souvenirArtName: String? {
        souvenir == nil ? nil : "souvenir_\(artKey)"
    }

    func sceneryArtName(_ layer: SceneryLayer) -> String {
        "trip_\(artKey)_\(layer.rawValue)"
    }
}
