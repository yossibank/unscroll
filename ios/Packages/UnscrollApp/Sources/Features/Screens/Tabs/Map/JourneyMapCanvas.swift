import Core
import DesignSystem
import SwiftUI

struct JourneyMapCanvas: View {
    let journey: Journey
    let kilometers: Int

    var body: some View {
        Canvas { context, size in
            drawSea(&context, size)
            drawLand(&context, size)
            drawMountains(&context, size)
            drawLakes(&context, size)
            drawFuji(&context, size)
            drawRoad(&context, size)
            drawLandmarks(&context, size)
            drawPosition(&context, size)
        }
        .aspectRatio(JourneyMapGeometry.aspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}

private extension JourneyMapCanvas {
    func drawSea(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let gradient = Gradient(colors: [Color(hex: 0xCFE6EA), Color(hex: 0xA9D3DC)])
        let shading = GraphicsContext.Shading.linearGradient(
            gradient,
            startPoint: .zero,
            endPoint: CGPoint(x: 0, y: size.height)
        )

        context.fill(Path(CGRect(origin: .zero, size: size)), with: shading)
    }

    func drawLand(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let path = polygon(JourneyMapGeometry.land, size)

        context.fill(path, with: .color(Color(hex: 0xEFE7D2)))
        context.stroke(path, with: .color(Color(hex: 0xC9BC9B)), lineWidth: 1.5)
    }

    func drawMountains(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let scale = size.width / 228
        let color = Color(red: 143 / 255, green: 179 / 255, blue: 140 / 255).opacity(0.35)

        for mountain in JourneyMapGeometry.mountains {
            let center = JourneyMapGeometry.project(mountain, in: size)
            var path = Path()
            path.move(to: CGPoint(x: center.x - 8 * scale, y: center.y + 5 * scale))
            path.addLine(to: CGPoint(x: center.x, y: center.y - 6 * scale))
            path.addLine(to: CGPoint(x: center.x + 8 * scale, y: center.y + 5 * scale))
            path.closeSubpath()

            context.fill(path, with: .color(color))
        }
    }

    func drawLakes(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let scale = size.width / 228
        let sea = Color(hex: 0xA9D3DC)
        let biwa = polygon(JourneyMapGeometry.biwa, size)

        context.fill(biwa, with: .color(sea))
        context.stroke(biwa, with: .color(Color(hex: 0x8FBCC6)), lineWidth: 1.5)

        if let hamana = JourneyMapGeometry.spots["浜名湖"] {
            let center = JourneyMapGeometry.project(hamana, in: size)
            let rect = CGRect(
                x: center.x - 5.5 * scale,
                y: center.y - 4.5 * scale,
                width: 7 * scale,
                height: 5 * scale
            )

            context.fill(Path(ellipseIn: rect), with: .color(sea))
        }
    }

    func drawFuji(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let scale = size.width / 228
        let center = JourneyMapGeometry.project(JourneyMapGeometry.fuji, in: size)
        var body = Path()
        body.move(to: CGPoint(x: center.x - 10 * scale, y: center.y + 6 * scale))
        body.addLine(to: CGPoint(x: center.x - 2 * scale, y: center.y - 6 * scale))
        body.addLine(to: CGPoint(x: center.x + 2 * scale, y: center.y - 6 * scale))
        body.addLine(to: CGPoint(x: center.x + 10 * scale, y: center.y + 6 * scale))
        body.closeSubpath()

        var snow = Path()
        snow.move(to: CGPoint(x: center.x - 2 * scale, y: center.y - 6 * scale))
        snow.addLine(to: CGPoint(x: center.x + 2 * scale, y: center.y - 6 * scale))
        snow.addLine(to: CGPoint(x: center.x + 4.5 * scale, y: center.y - 2 * scale))
        snow.addLine(to: CGPoint(x: center.x - 4.5 * scale, y: center.y - 2 * scale))
        snow.closeSubpath()

        context.fill(body, with: .color(Color(hex: 0x7D9CBF)))
        context.fill(snow, with: .color(.white))
    }

    func drawRoad(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let scale = size.width / 228
        let points = landmarkPoints(size)
        let position = currentPosition(size)
        let passed = points.filter { $0.kilometer <= kilometers }.map(\.point)
        let ahead = points.filter { $0.kilometer > kilometers }.map(\.point)

        var done = Path()
        done.addLines(passed + [position])

        var rest = Path()
        rest.addLines([position] + ahead)

        context.stroke(
            rest,
            with: .color(Color(hex: 0x9D8F70)),
            style: StrokeStyle(lineWidth: 2 * scale, dash: [3 * scale, 4 * scale])
        )
        context.stroke(
            done,
            with: .color(Palette.teal),
            style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round, lineJoin: .round)
        )
    }

    func drawLandmarks(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let scale = size.width / 228

        for item in landmarkPoints(size) {
            let isReached = item.kilometer <= kilometers
            let rect = CGRect(
                x: item.point.x - 4.5 * scale,
                y: item.point.y - 4.5 * scale,
                width: 9 * scale,
                height: 9 * scale
            )
            let fill = isReached ? Palette.coral : Color.white
            let edge = isReached ? Color(hex: 0xC9705F) : Color(hex: 0x9D8F70)

            context.fill(Path(ellipseIn: rect), with: .color(fill))
            context.stroke(Path(ellipseIn: rect), with: .color(edge), lineWidth: 1.5 * scale)

            if let offset = JourneyMapGeometry.labelOffsets[item.name] {
                let label = Text(item.name)
                    .font(.system(size: 7.5 * scale, weight: .bold, design: .rounded))
                    .foregroundStyle(isReached ? Palette.ink : Palette.muted)
                let at = CGPoint(
                    x: item.point.x + offset.width * scale,
                    y: item.point.y + offset.height * scale
                )

                context.draw(label, at: at)
            }
        }
    }

    func drawPosition(
        _ context: inout GraphicsContext,
        _ size: CGSize
    ) {
        let scale = size.width / 228
        let center = currentPosition(size)
        let radius = 11 * scale
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )

        context.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0xFBFAF6)))
        context.stroke(Path(ellipseIn: rect), with: .color(Palette.teal), lineWidth: 2 * scale)

        var symbol = context.resolve(Image(systemName: "figure.walk"))
        symbol.shading = .color(Palette.teal)
        let side = radius * 1.2

        context.draw(
            symbol,
            in: CGRect(x: center.x - side / 2, y: center.y - side / 2, width: side, height: side)
        )
    }

    func polygon(
        _ points: [CGPoint],
        _ size: CGSize
    ) -> Path {
        var path = Path()
        path.addLines(points.map { JourneyMapGeometry.project($0, in: size) })
        path.closeSubpath()
        return path
    }

    func landmarkPoints(_ size: CGSize) -> [LandmarkPoint] {
        journey.landmarks.compactMap { landmark in
            guard let spot = JourneyMapGeometry.spots[landmark.name] else {
                return nil
            }

            return LandmarkPoint(
                name: landmark.name,
                kilometer: landmark.kilometer,
                point: JourneyMapGeometry.project(spot, in: size)
            )
        }
    }

    func currentPosition(_ size: CGSize) -> CGPoint {
        let points = landmarkPoints(size)

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

        return CGPoint(
            x: from.point.x + (to.point.x - from.point.x) * ratio,
            y: from.point.y + (to.point.y - from.point.y) * ratio
        )
    }
}

private struct LandmarkPoint {
    let name: String
    let kilometer: Int
    let point: CGPoint
}
