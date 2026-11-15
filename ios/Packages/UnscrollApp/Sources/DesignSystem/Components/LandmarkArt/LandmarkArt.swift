import Core
import SwiftUI

public struct LandmarkArt: View {
    private let landmark: Landmark

    public init(landmark: Landmark) {
        self.landmark = landmark
    }

    public var body: some View {
        Image(landmark.artName, bundle: .module)
            .interpolation(.none)
            .resizable()
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
            .accessibilityLabel("\(landmark.name)の絵はがき")
    }
}

public extension LandmarkArt {
    static let aspectRatio: CGFloat = 160 / 100
}
