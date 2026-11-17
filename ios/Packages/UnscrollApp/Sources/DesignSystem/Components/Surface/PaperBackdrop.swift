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

                dots
            }
        }
        .ignoresSafeArea()
    }
}

private extension PaperBackdrop {
    var dots: some View {
        Canvas { context, size in
            var path = Path()
            var y: CGFloat = 8

            while y < size.height {
                var x: CGFloat = 8

                while x < size.width {
                    path.addEllipse(in: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                    x += 16
                }

                y += 16
            }

            context.fill(path, with: .color(Palette.ink.opacity(0.08)))
        }
    }
}

#Preview {
    PaperBackdrop()
}
