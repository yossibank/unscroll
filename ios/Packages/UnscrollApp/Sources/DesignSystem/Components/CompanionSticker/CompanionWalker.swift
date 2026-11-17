import Core
import SwiftUI

public struct CompanionWalker: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let companion: Companion
    private let size: CGFloat

    public init(
        companion: Companion,
        size: CGFloat
    ) {
        self.companion = companion
        self.size = size
    }

    public var body: some View {
        if reduceMotion {
            sticker(pose: .walk)
        } else {
            TimelineView(.periodic(from: .now, by: Self.interval)) { context in
                let step = Self.step(at: context.date)

                sticker(pose: step.isMultiple(of: 2) ? .walk : .walkLeft)
                    .keyframeAnimator(initialValue: CGFloat.zero, trigger: step) { content, lift in
                        content.offset(y: -lift)
                    } keyframes: { _ in
                        KeyframeTrack {
                            LinearKeyframe(Self.bounce, duration: Self.interval * 0.4)
                            LinearKeyframe(0, duration: Self.interval * 0.4)
                        }
                    }
            }
        }
    }
}

private extension CompanionWalker {
    static let interval: TimeInterval = 0.35
    static let bounce: CGFloat = 4

    func sticker(pose: Companion.Pose) -> some View {
        CompanionSticker(
            companion: companion,
            pose: pose,
            size: size,
            breathes: false
        )
    }

    static func step(at date: Date) -> Int {
        Int(date.timeIntervalSinceReferenceDate / interval)
    }
}

#Preview {
    if let companion = Companion(species: .shiba, coat: .black, name: "こむぎ") {
        CompanionWalker(companion: companion, size: 96)
            .padding(40)
    }
}
