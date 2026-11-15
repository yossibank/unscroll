import Core
import SwiftUI

public struct SouvenirArt: View {
    private let artName: String
    private let label: String
    private let size: CGFloat

    public init?(
        landmark: Landmark,
        size: CGFloat
    ) {
        guard
            let artName = landmark.souvenirArtName,
            let label = landmark.souvenir
        else {
            return nil
        }

        self.artName = artName
        self.label = label
        self.size = size
    }

    public var body: some View {
        Image(artName, bundle: .module)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
            .shadow(color: .white, radius: 0, x: outline, y: 0)
            .shadow(color: .white, radius: 0, x: -outline, y: 0)
            .shadow(color: .white, radius: 0, x: 0, y: outline)
            .shadow(color: .white, radius: 0, x: 0, y: -outline)
            .shadow(color: Palette.ink.opacity(0.22), radius: 4, x: 0, y: 4)
            .accessibilityLabel(label)
    }
}

private extension SouvenirArt {
    var outline: CGFloat {
        max(size / 48, 2)
    }
}
