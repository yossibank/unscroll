import SwiftUI

public struct LuggageTagShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let cut = min(rect.height / 2.5, 14)
        let radius: CGFloat = 8
        let hole = rect.height / 5

        var outline = Path()
        outline.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        outline.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))

        outline.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        outline.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))

        outline.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        outline.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
        outline.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cut))
        outline.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
        outline.closeSubpath()

        let eyelet = Path(ellipseIn: CGRect(
            x: rect.minX + cut * 0.9 - hole / 2,
            y: rect.midY - hole / 2,
            width: hole,
            height: hole
        ))

        return outline.subtracting(eyelet)
    }
}
