import Core
import DesignSystem
import SwiftUI

struct PostcardArt: View {
    let landmark: Landmark

    var body: some View {
        LandmarkArt(landmark: landmark)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
