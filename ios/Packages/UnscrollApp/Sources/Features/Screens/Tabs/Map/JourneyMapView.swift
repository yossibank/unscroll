import DesignSystem
import SwiftUI

public struct JourneyMapView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "東京 → 京都の地図",
                systemImage: "map",
                description: Text("名所と今いる場所の地図は、あとで作ります。")
            )
            .background(Palette.paper)
            .navigationTitle("地図")
        }
    }
}
