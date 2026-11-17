import Core
import SwiftUI

public struct LaunchScenery: View {
    private let companion: Companion?
    private let pose: Companion.Pose
    private let dawn: Double
    private let travel: CGFloat
    private let lift: CGFloat
    private let holdsBag: Bool

    public init(
        companion: Companion?,
        pose: Companion.Pose,
        dawn: Double,
        travel: CGFloat,
        lift: CGFloat,
        holdsBag: Bool
    ) {
        self.companion = companion
        self.pose = pose
        self.dawn = dawn
        self.travel = travel
        self.lift = lift
        self.holdsBag = holdsBag
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack(alignment: .topLeading) {
                sky

                stars(in: size)
                    .opacity(nightAmount)

                Image(systemName: "moon.fill")
                    .font(.system(size: size.width * 0.12))
                    .foregroundStyle(Palette.sunSoft)
                    .shadow(color: Palette.sunSoft.opacity(0.5), radius: 12)
                    .position(x: size.width * 0.74, y: size.height * 0.16)
                    .opacity(nightAmount)

                sun(in: size)

                clouds(in: size)
                    .opacity(dayAmount)

                land(in: size)

                footprints(in: size)

                if let companion {
                    traveler(companion, in: size)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

public extension LaunchScenery {
    static func sunCenter(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2, y: size.height * horizon)
    }
}

private extension LaunchScenery {
    static let horizon: CGFloat = 0.58
    static let nightTint = Color(hex: 0x1E2350)

    static let stars: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.1, 0.2, 3),
        (0.3, 0.1, 2.4),
        (0.8, 0.12, 2.8),
        (0.62, 0.34, 2),
        (0.2, 0.5, 2.4),
        (0.9, 0.55, 2.2),
        (0.48, 0.07, 2.6),
        (0.38, 0.4, 1.8)
    ]

    var sky: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0x1E2350),
                    Color(hex: 0x2B2F5C),
                    Color(hex: 0x4A3F7A),
                    Color(hex: 0x6B4FA3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color(hex: 0x5B4E8F),
                    Color(hex: 0xC98BA7),
                    Color(hex: 0xF9B88C),
                    Color(hex: 0xFDE3A8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(min(dawn, 1))

            LinearGradient(
                colors: [
                    Color(hex: 0xF7A38E),
                    Color(hex: 0xFBC48A),
                    Color(hex: 0xFDE6B2),
                    Color(hex: 0xFFF5DA)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(dayAmount)
        }
    }

    func stars(in size: CGSize) -> some View {
        ForEach(Self.stars.indices, id: \.self) { index in
            let star = Self.stars[index]

            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: star.size, height: star.size)
                .position(
                    x: size.width * star.x,
                    y: size.height * Self.horizon * star.y
                )
        }
    }

    func sun(in size: CGSize) -> some View {
        let radius = size.width * 0.13
        let center = Self.sunCenter(in: size)
        let sink = (1 - min(max(dawn / 2, 0), 1)) * radius * 1.6

        return ZStack {
            SunRays()
                .fill(.white.opacity(0.13))
                .frame(width: radius * 8, height: radius * 8)
                .opacity(dayAmount)

            Circle()
                .fill(Palette.sun.opacity(0.18))
                .frame(width: radius * 4.2, height: radius * 4.2)

            Circle()
                .fill(Palette.sunSoft.opacity(0.35))
                .frame(width: radius * 2.9, height: radius * 2.9)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: 0xFFF4C9), Palette.sun, Color(hex: 0xF3A54B)],
                        center: .center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
                .frame(width: radius * 2, height: radius * 2)
        }
        .position(x: center.x, y: center.y + sink)
    }

    func clouds(in size: CGSize) -> some View {
        ZStack {
            Cloud()
                .frame(width: size.width * 0.28, height: size.width * 0.12)
                .position(x: size.width * 0.22, y: size.height * 0.17)

            Cloud()
                .frame(width: size.width * 0.2, height: size.width * 0.09)
                .position(x: size.width * 0.8, y: size.height * 0.27)
                .opacity(0.8)
        }
    }

    func land(in size: CGSize) -> some View {
        let horizon = Self.horizon
        let shade = Self.nightTint.opacity(0.55 * nightAmount)

        return ZStack {
            Hills(horizon: horizon, isFar: true)
                .fill(Color(hex: 0xC99AB8))
                .overlay(Hills(horizon: horizon, isFar: true).fill(shade))

            Hills(horizon: horizon, isFar: false)
                .fill(Color(hex: 0xE2A9A0))
                .overlay(Hills(horizon: horizon, isFar: false).fill(shade))

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x9BCB86), Color(hex: 0x6FAE77)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(shade)
                .frame(height: size.height * (1 - horizon))
                .frame(maxHeight: .infinity, alignment: .bottom)

            Road(horizon: horizon)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xE9C99A), Color(hex: 0xD9AE76)],
                        startPoint: UnitPoint(x: 0.5, y: horizon),
                        endPoint: .bottom
                    )
                )
                .overlay(Road(horizon: horizon).fill(shade))
        }
        .frame(width: size.width, height: size.height)
    }

    func footprints(in size: CGSize) -> some View {
        ForEach(0..<4, id: \.self) { index in
            let step = CGFloat(index + 1) / 5
            let point = trail(at: step, in: size)
            let width = size.width * 0.03 * (1 - step * 0.7)

            Ellipse()
                .fill(Color(hex: 0xB98E5A).opacity(0.55))
                .frame(width: width, height: width * 0.6)
                .position(x: point.x + (index.isMultiple(of: 2) ? -width : width), y: point.y)
                .opacity(travel >= step ? 1 : 0)
        }
    }

    func traveler(
        _ companion: Companion,
        in size: CGSize
    ) -> some View {
        let near = size.width * 0.42
        let far = size.width * 0.07
        let side = near + (far - near) * travel
        let foot = trail(at: travel, in: size)

        return LaunchTraveler(
            companion: companion,
            pose: pose,
            size: side,
            lift: lift,
            holdsBag: holdsBag
        )
        .frame(width: side, height: side)
        .position(x: foot.x, y: foot.y - side / 2)
    }
}

private extension LaunchScenery {
    var nightAmount: Double {
        max(0, 1 - dawn)
    }

    var dayAmount: Double {
        min(max(dawn - 1, 0), 1)
    }

    func trail(
        at progress: CGFloat,
        in size: CGSize
    ) -> CGPoint {
        let near = size.height * 0.9
        let far = size.height * Self.horizon + size.width * 0.02
        return CGPoint(x: size.width / 2, y: near + (far - near) * progress)
    }
}

private struct SunRays: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let length = min(rect.width, rect.height) / 2
        var path = Path()

        for index in 0..<14 {
            let angle = Double(index) * .pi / 7

            path.move(to: center)
            path.addLine(to: point(center, angle - 0.09, length))
            path.addLine(to: point(center, angle + 0.09, length))
            path.closeSubpath()
        }

        return path
    }

    func point(
        _ center: CGPoint,
        _ angle: Double,
        _ length: CGFloat
    ) -> CGPoint {
        CGPoint(x: center.x + cos(angle) * length, y: center.y + sin(angle) * length)
    }
}

private struct Cloud: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Ellipse()
                    .frame(width: width, height: height * 0.6)
                    .offset(y: height * 0.2)

                Circle()
                    .frame(width: width * 0.38, height: width * 0.38)
                    .offset(x: -width * 0.15, y: -height * 0.05)

                Circle()
                    .frame(width: width * 0.46, height: width * 0.46)
                    .offset(x: width * 0.14, y: -height * 0.12)
            }
            .frame(width: width, height: height)
            .foregroundStyle(.white.opacity(0.9))
        }
    }
}

private struct Hills: Shape {
    let horizon: CGFloat
    let isFar: Bool

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let base = rect.height * horizon
        var path = Path()

        if isFar {
            path.move(to: CGPoint(x: 0, y: base))
            path.addLine(to: CGPoint(x: 0, y: base - width * 0.1))
            path.addQuadCurve(
                to: CGPoint(x: width * 0.24, y: base - width * 0.09),
                control: CGPoint(x: width * 0.12, y: base - width * 0.2)
            )
            path.addQuadCurve(
                to: CGPoint(x: width * 0.42, y: base - width * 0.06),
                control: CGPoint(x: width * 0.33, y: base - width * 0.16)
            )
            path.addLine(to: CGPoint(x: width * 0.42, y: base))
            path.closeSubpath()

            path.move(to: CGPoint(x: width * 0.55, y: base))
            path.addQuadCurve(
                to: CGPoint(x: width * 0.8, y: base - width * 0.08),
                control: CGPoint(x: width * 0.68, y: base - width * 0.17)
            )
            path.addQuadCurve(
                to: CGPoint(x: width, y: base - width * 0.11),
                control: CGPoint(x: width * 0.9, y: base - width * 0.2)
            )
            path.addLine(to: CGPoint(x: width, y: base))
            path.closeSubpath()
        } else {
            path.move(to: CGPoint(x: 0, y: base))
            path.addQuadCurve(
                to: CGPoint(x: width * 0.38, y: base - width * 0.02),
                control: CGPoint(x: width * 0.2, y: base - width * 0.07)
            )
            path.addQuadCurve(
                to: CGPoint(x: width * 0.78, y: base - width * 0.025),
                control: CGPoint(x: width * 0.6, y: base - width * 0.08)
            )
            path.addQuadCurve(
                to: CGPoint(x: width, y: base - width * 0.03),
                control: CGPoint(x: width * 0.9, y: base - width * 0.06)
            )
            path.addLine(to: CGPoint(x: width, y: base + 1))
            path.addLine(to: CGPoint(x: 0, y: base + 1))
            path.closeSubpath()
        }

        return path
    }
}

private struct Road: Shape {
    let horizon: CGFloat

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let top = rect.height * horizon
        let middle = top + (rect.height - top) / 2
        let center = width / 2
        var path = Path()

        path.move(to: CGPoint(x: center - width * 0.01, y: top))
        path.addQuadCurve(
            to: CGPoint(x: center - width * 0.34, y: rect.height),
            control: CGPoint(x: center - width * 0.06, y: middle)
        )
        path.addLine(to: CGPoint(x: center + width * 0.34, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: center + width * 0.01, y: top),
            control: CGPoint(x: center + width * 0.06, y: middle)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    LaunchScenery(
        companion: .starter,
        pose: .jump,
        dawn: 2,
        travel: 0,
        lift: 0,
        holdsBag: true
    )
    .ignoresSafeArea()
}
