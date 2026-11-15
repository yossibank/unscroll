import Core
import DesignSystem
import SwiftUI

struct JourneyRoute: View {
    let journey: Journey
    let companion: Companion?
    let start: Int
    let end: Int

    var body: some View {
        VStack(spacing: Spacing.small) {
            GeometryReader { proxy in
                let width = proxy.size.width

                ZStack(alignment: .topLeading) {
                    Capsule()
                        .fill(Palette.muted.opacity(0.25))
                        .frame(width: width, height: 4)
                        .offset(y: Self.lineY - 2)

                    Capsule()
                        .fill(Palette.teal)
                        .frame(width: x(end, in: width), height: 4)
                        .offset(y: Self.lineY - 2)

                    Capsule()
                        .fill(Palette.coral)
                        .frame(width: x(end, in: width) - x(start, in: width), height: 6)
                        .offset(x: x(start, in: width), y: Self.lineY - 3)

                    ForEach(journey.landmarks, id: \.name) { landmark in
                        dot(isReached: landmark.kilometer <= end)
                            .position(x: x(landmark.kilometer, in: width), y: Self.lineY)
                    }

                    if let companion {
                        CompanionSticker(
                            companion: companion,
                            pose: .walk,
                            size: 32,
                            breathes: false
                        )
                        .position(x: x(end, in: width), y: Self.lineY - 24)
                    }
                }
            }
            .frame(height: Self.lineY + 8)
            .padding(.horizontal, Spacing.small)

            HStack {
                Text(journey.landmarks.first?.name ?? "")

                Spacer()

                Text(journey.landmarks.last?.name ?? "")
            }
            .font(.caption2)
            .foregroundStyle(Palette.muted)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(journey.totalKilometers) km のうち \(end) km")
    }
}

private extension JourneyRoute {
    static let lineY: CGFloat = 44

    func dot(isReached: Bool) -> some View {
        Circle()
            .fill(isReached ? Palette.teal : Palette.card)
            .frame(width: 16, height: 16)
            .overlay {
                Circle()
                    .strokeBorder(
                        isReached ? Palette.teal : Palette.muted.opacity(0.3),
                        lineWidth: 3
                    )
            }
    }

    func x(
        _ kilometers: Int,
        in width: CGFloat
    ) -> CGFloat {
        let total = max(journey.totalKilometers, 1)
        let ratio = CGFloat(min(max(kilometers, 0), total)) / CGFloat(total)
        return width * ratio
    }
}
