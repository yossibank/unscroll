import DesignSystem
import SwiftUI

public struct PostcardAlbumView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "絵はがきの図鑑",
                systemImage: "photo.on.rectangle",
                description: Text("名所に着くと届く絵はがきは、あとで作ります。")
            )
            .background(Palette.paper)
            .navigationTitle("絵はがき")
        }
    }
}
