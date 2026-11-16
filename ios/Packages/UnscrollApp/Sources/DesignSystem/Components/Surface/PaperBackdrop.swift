import SwiftUI

public struct PaperBackdrop: View {
    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            let radius = proxy.size.width * 0.9

            ZStack {
                LinearGradient(
                    colors: [Palette.paper, Palette.paperDeep],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RadialGradient(
                    colors: [Palette.sunSoft, Palette.sunSoft.opacity(0)],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: radius
                )

                RadialGradient(
                    colors: [Palette.tealSoft, Palette.tealSoft.opacity(0)],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: radius
                )
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PaperBackdrop()
}
