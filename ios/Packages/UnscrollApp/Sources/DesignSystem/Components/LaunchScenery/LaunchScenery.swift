import Core
import SwiftUI

public struct LaunchScenery: View {
    private let companion: Companion?
    private let pose: Companion.Pose
    private let dawn: Double

    public init(
        companion: Companion?,
        pose: Companion.Pose,
        dawn: Double
    ) {
        self.companion = companion
        self.pose = pose
        self.dawn = dawn
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let center = Self.sunCenter(in: size)
            let side = size.width * 0.28

            ZStack(alignment: .topLeading) {
                sky

                night(in: size)
                    .opacity(nightAmount)

                sun(in: size)

                ground
                    .frame(height: size.height - center.y)
                    .offset(y: center.y)

                Rectangle()
                    .fill(horizonTint)
                    .frame(height: 2)
                    .offset(y: center.y - 1)

                if let companion {
                    CompanionSticker(
                        companion: companion,
                        pose: pose,
                        size: side,
                        breathes: false
                    )
                    .position(x: center.x, y: center.y - side / 2)
                }
            }
        }
        .accessibilityHidden(true)
    }
}

public extension LaunchScenery {
    static func sunCenter(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width / 2, y: size.height * 0.56)
    }
}

private extension LaunchScenery {
    static let stars: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.15, 0.12, 3),
        (0.4, 0.07, 2.4),
        (0.6, 0.18, 2),
        (0.2, 0.3, 2.4),
        (0.86, 0.32, 2.2),
        (0.32, 0.42, 1.8)
    ]

    var horizonTint: Color {
        dayAmount > 0.5 ? Palette.ink : Palette.sunSoft
    }

    var nightAmount: Double {
        max(0, 1 - dawn)
    }

    var dayAmount: Double {
        min(max(dawn - 1, 0), 1)
    }

    var sky: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x1E2350), Color(hex: 0x2B2F5C)],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [Color(hex: 0x5B4E8F), Color(hex: 0xF9B88C)],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(min(dawn, 1))

            LinearGradient(
                colors: [Color(hex: 0xFBC48A), Color(hex: 0xFFF5DA)],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(dayAmount)
        }
    }

    var ground: some View {
        ZStack {
            Color(hex: 0x1E2350)

            Color(hex: 0x4A3F7A)
                .opacity(min(dawn, 1))

            Palette.paper
                .opacity(dayAmount)
        }
    }

    func night(in size: CGSize) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(Self.stars.indices, id: \.self) { index in
                let star = Self.stars[index]

                Circle()
                    .fill(.white.opacity(0.9))
                    .frame(width: star.size, height: star.size)
                    .position(x: size.width * star.x, y: size.height * star.y)
            }

            Image(systemName: "moon.fill")
                .font(.system(size: size.width * 0.09))
                .foregroundStyle(Palette.sunSoft)
                .shadow(color: Palette.sunSoft.opacity(0.5), radius: 12)
                .position(x: size.width * 0.74, y: size.height * 0.16)
        }
    }

    func sun(in size: CGSize) -> some View {
        let radius = size.width * 0.1
        let center = Self.sunCenter(in: size)
        let sink = (1 - min(max(dawn / 2, 0), 1)) * radius * 1.4

        return ZStack {
            Circle()
                .fill(Palette.sun.opacity(0.2))
                .frame(width: radius * 3.2, height: radius * 3.2)

            Circle()
                .fill(Palette.sun)
                .frame(width: radius * 2, height: radius * 2)
        }
        .position(x: center.x, y: center.y + sink)
    }
}

#Preview {
    LaunchScenery(
        companion: .starter,
        pose: .wave,
        dawn: 2
    )
    .ignoresSafeArea()
}
