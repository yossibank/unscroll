import Core
import DesignSystem
import SwiftUI

struct RoomScene: View {
    let companion: Companion?
    let look: RoomLook
    let pose: Companion.Pose
    let window: Landmark?
    let postcards: [Landmark]
    let nextRemaining: Int?
    let souvenirs: [Landmark]
    let onPoke: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let period = DayPeriod(date: context.date)

            GeometryReader { proxy in
                let scale = proxy.size.width / RoomBackdrop.width

                ZStack(alignment: .topLeading) {
                    windowView(period, scale: scale)

                    RoomBackdrop(look: look)

                    postcardsView(scale: scale)

                    souvenirsView(scale: scale)

                    if let shade = period.roomShade {
                        shade

                        RadialGradient(
                            colors: [period.lampGlow, .clear],
                            center: Self.lampCenter,
                            startRadius: 0,
                            endRadius: 60 * scale
                        )
                    }

                    companionView(scale: scale)
                }
            }
            .aspectRatio(RoomBackdrop.aspectRatio, contentMode: .fit)
        }
    }
}

private extension RoomScene {
    static let pane = CGRect(x: 13, y: 15, width: 66, height: 44)
    static let postcardSlots: [(x: CGFloat, y: CGFloat, angle: Double)] = [
        (98, 15, -4),
        (125, 16, 3),
        (152, 15, -2)
    ]
    static let postcardSize = CGSize(width: 22, height: 14)
    static let souvenirStart = CGPoint(x: 100, y: 42)
    static let souvenirSize: CGFloat = 12
    static let companionSize: CGFloat = 56
    static let companionCenterX: CGFloat = 90
    static let companionBottom: CGFloat = 124
    static let lampCenter = UnitPoint(x: 90 / 180, y: 100 / 140)

    @ViewBuilder
    func windowView(
        _ period: DayPeriod,
        scale: CGFloat
    ) -> some View {
        if let window {
            TripScenery(
                landmark: window,
                period: period,
                isMoving: false
            )
            .frame(width: Self.pane.width * scale, height: Self.pane.height * scale)
            .clipped()
            .offset(x: Self.pane.minX * scale, y: Self.pane.minY * scale)
        }
    }

    func postcardsView(scale: CGFloat) -> some View {
        let width = Self.postcardSize.width * scale
        let height = Self.postcardSize.height * scale

        return ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
            let position = Self.postcardSlots[index]

            Group {
                if let landmark = slot {
                    LandmarkArt(landmark: landmark)
                        .frame(width: width, height: height)
                        .padding(scale)
                        .background(Palette.card)
                        .shadow(color: Palette.ink.opacity(0.3), radius: scale, y: scale)
                } else if let nextRemaining {
                    nextSlot(nextRemaining, scale: scale)
                        .frame(width: width + 2 * scale, height: height + 2 * scale)
                }
            }
            .overlay(alignment: .top) {
                if slot != nil {
                    Rectangle()
                        .fill(Palette.floorEdge)
                        .frame(width: 3 * scale, height: 5 * scale)
                        .offset(y: -2 * scale)
                }
            }
            .rotationEffect(.degrees(slot == nil ? 0 : position.angle), anchor: .top)
            .offset(x: position.x * scale, y: position.y * scale)
        }
    }

    func nextSlot(
        _ remaining: Int,
        scale: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            Text("次の絵はがき")
            Text("あと \(remaining) km")
        }
        .font(.system(size: 4 * scale))
        .foregroundStyle(Palette.muted)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            Rectangle()
                .stroke(
                    Palette.floorEdge,
                    style: StrokeStyle(lineWidth: scale, dash: [3 * scale, 2 * scale])
                )
        }
    }

    func souvenirsView(scale: CGFloat) -> some View {
        let size = Self.souvenirSize * scale

        return ForEach(Array(souvenirs.enumerated()), id: \.offset) { index, landmark in
            if let art = SouvenirArt(landmark: landmark, size: size) {
                art
                    .offset(
                        x: (Self.souvenirStart.x + CGFloat(index) * Self.souvenirSize) * scale,
                        y: Self.souvenirStart.y * scale
                    )
            }
        }
    }

    @ViewBuilder
    func companionView(scale: CGFloat) -> some View {
        if let companion {
            let size = Self.companionSize * scale

            Button {
                onPoke()
            } label: {
                CompanionSticker(companion: companion, pose: pose, size: size)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(companion.name)
            .offset(
                x: Self.companionCenterX * scale - size / 2,
                y: Self.companionBottom * scale - size
            )
        }
    }
}

private extension RoomScene {
    var slots: [Landmark?] {
        guard nextRemaining != nil else {
            return postcards.suffix(3).map(Optional.some)
        }

        return postcards.suffix(2).map(Optional.some) + [nil]
    }
}
