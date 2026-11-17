import SwiftUI

public struct MaskingTape: View {
    private let tint: Color
    private let width: CGFloat

    public init(
        tint: Color,
        width: CGFloat = 64
    ) {
        self.tint = tint
        self.width = width
    }

    public var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)

            context.fill(Path(rect), with: .color(tint.opacity(0.8)))

            var stripes = Path()
            var x = -size.height

            while x < size.width {
                stripes.move(to: CGPoint(x: x, y: size.height))
                stripes.addLine(to: CGPoint(x: x + size.height, y: 0))
                x += 10
            }

            context.stroke(stripes, with: .color(.white.opacity(0.3)), lineWidth: 4)
        }
        .frame(width: width, height: 20)
        .mask(TapeEdge())
        .accessibilityHidden(true)
    }
}

private struct TapeEdge: Shape {
    func path(in rect: CGRect) -> Path {
        let teeth = 5
        let step = rect.height / CGFloat(teeth)

        var path = Path()

        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))

        for index in 0..<teeth {
            let y = CGFloat(index) * step
            path.addLine(to: CGPoint(x: rect.maxX - 3, y: y + step / 2))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + step))
        }

        path.addLine(to: CGPoint(x: 0, y: rect.maxY))

        for index in (0..<teeth).reversed() {
            let y = CGFloat(index) * step
            path.addLine(to: CGPoint(x: 3, y: y + step / 2))
            path.addLine(to: CGPoint(x: 0, y: y))
        }

        path.closeSubpath()

        return path
    }
}

#Preview {
    VStack(spacing: 24) {
        MaskingTape(tint: Palette.coral)

        MaskingTape(tint: Palette.sun, width: 80)
            .rotationEffect(.degrees(-6))
    }
    .padding()
    .background(PaperBackdrop())
}
