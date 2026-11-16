import Core
import DesignSystem
import SwiftUI

struct JourneyMapCanvas: View {
    let journey: Journey
    let geometry: JourneyMapGeometry
    let kilometers: Int
    let companion: Companion?

    var body: some View {
        MapBackdrop(name: geometry.backdrop)
            .overlay {
                GeometryReader { proxy in
                    let unit = proxy.size.width / MapBackdrop.width

                    ZStack(alignment: .topLeading) {
                        Canvas { context, _ in
                            drawRoad(&context, unit)
                            drawLandmarks(&context, unit)
                            drawLabels(&context, unit)
                        }

                        marker(unit)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement()
            .accessibilityLabel(accessibilityText)
    }
}

private extension JourneyMapCanvas {
    @ViewBuilder
    func marker(_ unit: CGFloat) -> some View {
        let point = currentPosition()
        let frame = markerFrame(unit)

        if let companion {
            CompanionSticker(
                companion: companion,
                pose: .walkLeft,
                size: frame.width,
                breathes: false
            )
            .position(x: frame.midX, y: frame.midY)
        } else {
            Rectangle()
                .fill(Palette.teal)
                .frame(width: 4 * unit, height: 4 * unit)
                .position(x: point.x * unit, y: point.y * unit)
        }
    }
}

private extension JourneyMapCanvas {
    static let passed = Color(hex: 0xC9705F)
    static let ahead = Color(hex: 0x7A6A4E)
    static let outline = Color(hex: 0x4A3428)
    static let markerSide: CGFloat = 16
    static let markerLift: CGFloat = 6
    static let labelBelow: CGFloat = 10

    var accessibilityText: String {
        let reached = landmarkPoints().filter { $0.kilometer <= kilometers }.map(\.name)
        let names = reached.joined(separator: "、")
        return "\(journey.name)の地図。\(kilometers) km 進んだ。通った名所は \(names)"
    }

    func drawRoad(
        _ context: inout GraphicsContext,
        _ unit: CGFloat
    ) {
        let points = landmarkPoints()
        let position = currentPosition()
        let done = points.filter { $0.kilometer <= kilometers }.map(\.point) + [position]
        let rest = [position] + points.filter { $0.kilometer > kilometers }.map(\.point)

        for pixel in pixels(along: rest) where (Int(pixel.x) + Int(pixel.y)) % 3 != 0 {
            fill(&context, pixel, side: 1, color: Self.ahead, unit: unit)
        }

        for pixel in pixels(along: done) {
            fill(
                &context,
                CGPoint(x: pixel.x, y: pixel.y + 1),
                side: 2,
                color: Self.outline,
                unit: unit
            )
            fill(&context, pixel, side: 2, color: Self.passed, unit: unit)
        }
    }

    func drawLandmarks(
        _ context: inout GraphicsContext,
        _ unit: CGFloat
    ) {
        let next = journey.nextLandmark(after: kilometers)?.name

        for item in landmarkPoints() {
            let isReached = item.kilometer <= kilometers
            let isNext = item.name == next
            let face = isReached ? Palette.coral : Color.white
            let corner = CGPoint(x: item.point.x - 2, y: item.point.y - 2)

            if isNext {
                let ring = CGPoint(x: item.point.x - 4, y: item.point.y - 4)
                fill(&context, ring, side: 9, color: Color(hex: 0xF2C14E), unit: unit)
            }

            fill(
                &context,
                CGPoint(x: corner.x - 1, y: corner.y - 1),
                side: 7,
                color: Self.outline,
                unit: unit
            )
            fill(&context, corner, side: 5, color: face, unit: unit)

            if isReached {
                fill(
                    &context,
                    CGPoint(x: corner.x + 1, y: corner.y + 1),
                    side: 1,
                    color: .white,
                    unit: unit
                )
            }
        }
    }

    func drawLabels(
        _ context: inout GraphicsContext,
        _ unit: CGFloat
    ) {
        let next = journey.nextLandmark(after: kilometers)?.name

        for item in landmarkPoints() {
            guard let offset = geometry.labelOffsets[item.name] else {
                continue
            }

            let isLit = item.kilometer <= kilometers || item.name == next
            let color = isLit ? Palette.ink : Palette.muted
            let label = Text(item.name)
                .font(.system(size: 6.5 * unit, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            let resolved = context.resolve(label)
            let size = resolved.measure(in: CGSize(width: 200 * unit, height: 40 * unit))
            let above = labelPlate(
                at: item.point,
                offset: offset,
                size: size,
                unit: unit
            )
            let isCovered = companion != nil && above.intersects(markerFrame(unit))
            let shifted = isCovered ? CGSize(width: offset.width, height: Self.labelBelow) : offset
            let plate = labelPlate(
                at: item.point,
                offset: shifted,
                size: size,
                unit: unit
            )
            let opacity = isLit ? 0.92 : 0.7

            context.fill(Path(plate), with: .color(Color(hex: 0xFBFAF6).opacity(opacity)))
            context.draw(resolved, at: CGPoint(x: plate.midX, y: plate.midY))
        }
    }

    func labelPlate(
        at point: CGPoint,
        offset: CGSize,
        size: CGSize,
        unit: CGFloat
    ) -> CGRect {
        let center = CGPoint(
            x: (point.x + offset.width) * unit,
            y: (point.y + offset.height) * unit
        )

        return CGRect(
            x: center.x - size.width / 2 - 2 * unit,
            y: center.y - size.height / 2 - 0.5 * unit,
            width: size.width + 4 * unit,
            height: size.height + unit
        )
    }

    func markerFrame(_ unit: CGFloat) -> CGRect {
        let point = currentPosition()
        let side = Self.markerSide * unit

        return CGRect(
            x: point.x * unit - side / 2,
            y: (point.y - Self.markerLift) * unit - side / 2,
            width: side,
            height: side
        )
    }

    func fill(
        _ context: inout GraphicsContext,
        _ pixel: CGPoint,
        side: CGFloat,
        color: Color,
        unit: CGFloat
    ) {
        let rect = CGRect(
            x: pixel.x * unit,
            y: pixel.y * unit,
            width: side * unit,
            height: side * unit
        )

        context.fill(Path(rect), with: .color(color))
    }

    func pixels(along points: [CGPoint]) -> [CGPoint] {
        zip(points, points.dropFirst()).flatMap { from, to in
            let steps = Int(max(abs(to.x - from.x), abs(to.y - from.y)).rounded())

            return (0...max(steps, 1)).map { step in
                let ratio = CGFloat(step) / CGFloat(max(steps, 1))
                let x = from.x + (to.x - from.x) * ratio
                let y = from.y + (to.y - from.y) * ratio
                return CGPoint(x: x.rounded(.down), y: y.rounded(.down))
            }
        }
    }

    func landmarkPoints() -> [LandmarkPoint] {
        journey.landmarks.compactMap { landmark in
            guard let spot = geometry.spots[landmark.name] else {
                return nil
            }

            let point = geometry.pixel(spot)

            return LandmarkPoint(
                name: landmark.name,
                kilometer: landmark.kilometer,
                point: CGPoint(x: point.x.rounded(), y: point.y.rounded())
            )
        }
    }

    func currentPosition() -> CGPoint {
        let points = landmarkPoints()

        guard let first = points.first, let last = points.last else {
            return .zero
        }

        guard kilometers > first.kilometer else {
            return first.point
        }

        guard kilometers < last.kilometer else {
            return last.point
        }

        guard
            let next = points.firstIndex(where: { $0.kilometer > kilometers }),
            next > 0
        else {
            return last.point
        }

        let from = points[next - 1]
        let to = points[next]
        let ratio = Double(kilometers - from.kilometer) / Double(to.kilometer - from.kilometer)
        let x = from.point.x + (to.point.x - from.point.x) * ratio
        let y = from.point.y + (to.point.y - from.point.y) * ratio

        return CGPoint(x: x.rounded(), y: y.rounded())
    }
}

private struct LandmarkPoint {
    let name: String
    let kilometer: Int
    let point: CGPoint
}
