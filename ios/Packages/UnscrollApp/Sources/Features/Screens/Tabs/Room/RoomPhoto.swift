import Core
import DesignSystem
import SwiftUI

struct RoomPhoto: View {
    let model: RoomModel
    let pose: Companion.Pose
    let onPoke: () -> Void

    var body: some View {
        TapedPhoto(caption: caption) {
            companionScene
        }
    }
}

private extension RoomPhoto {
    var companionScene: some View {
        RoomScene(
            companion: model.companion,
            look: model.look,
            pose: pose,
            window: model.nextLandmark ?? model.journey.landmarks.last,
            postcards: model.hungPostcards,
            nextRemaining: model.kilometersToNext,
            souvenirs: model.arrivals.map(\.landmark).filter { $0.souvenir != nil },
            onPoke: onPoke
        )
        .overlay {
            GeometryReader { proxy in
                bubble
                    .position(x: proxy.size.width * 0.27, y: proxy.size.height * 0.5)
            }
            .allowsHitTesting(false)
        }
        .overlay(alignment: .bottomLeading) {
            if let companion = model.companion {
                Text(companion.name)
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, Spacing.small + 4)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.92), in: Capsule())
                    .padding(Spacing.small + 4)
                    .allowsHitTesting(false)
            }
        }
    }

    var bubble: some View {
        Text(pose == .joy ? "うれしい！" : "そろそろ出かける？")
            .font(.caption2.weight(.heavy))
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, 4)
            .background(alignment: .bottomTrailing) {
                Image(systemName: "triangleshape.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(150))
                    .offset(x: 2, y: 4)
            }
            .background(.white, in: Capsule())
            .shadow(color: Palette.ink.opacity(0.12), radius: 4, y: 3)
            .contentTransition(.opacity)
            .animation(.snappy, value: pose == .joy)
    }
}

private extension RoomPhoto {
    var caption: String {
        let format = Date.VerbatimFormatStyle(
            format: "\(month: .defaultDigits)/\(day: .defaultDigits)",
            timeZone: .current,
            calendar: .current
        )

        let date = Date.now.formatted(format)

        guard let companion = model.companion else {
            return "\(date)　部屋で"
        }

        return "\(date)　\(companion.name)と部屋で"
    }
}
