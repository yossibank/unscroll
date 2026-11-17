import Core
import SwiftUI

public struct CompanionSticker: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var hops = 0

    private let companion: Companion
    private let pose: Companion.Pose
    private let size: CGFloat
    private let breathes: Bool

    public init(
        companion: Companion,
        pose: Companion.Pose,
        size: CGFloat,
        breathes: Bool = true
    ) {
        self.companion = companion
        self.pose = pose
        self.size = size
        self.breathes = breathes
    }

    public var body: some View {
        breathing
            .hop(trigger: hops, height: size * 0.12)
            .onChange(of: pose) { _, newPose in
                guard Self.lively.contains(newPose) else {
                    return
                }

                hops += 1
            }
    }
}

private extension CompanionSticker {
    static let lively: Set<Companion.Pose> = [.joy, .jump, .surprise]

    @ViewBuilder
    var breathing: some View {
        if breathes, !reduceMotion {
            art
                .phaseAnimator([false, true]) { content, phase in
                    content
                        .scaleEffect(x: 1, y: breathScale(phase), anchor: .bottom)
                } animation: { _ in
                    .easeInOut(duration: 1.2)
                }
        } else {
            art
        }
    }

    var art: some View {
        Image(companion.artName(pose), bundle: .module)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
            .shadow(color: .white, radius: 0, x: outline, y: 0)
            .shadow(color: .white, radius: 0, x: -outline, y: 0)
            .shadow(color: .white, radius: 0, x: 0, y: outline)
            .shadow(color: .white, radius: 0, x: 0, y: -outline)
            .shadow(color: Palette.ink.opacity(0.22), radius: 4, x: 0, y: 4)
            .accessibilityLabel(accessibilityText)
            .transaction { transaction in
                transaction.animation = nil
            }
    }
}

private extension CompanionSticker {
    var outline: CGFloat {
        max(size / 32, 2)
    }

    var accessibilityText: String {
        "\(companion.kindLabel)の\(companion.name)"
    }

    func breathScale(_ phase: Bool) -> CGFloat {
        phase ? 0.97 : 1
    }
}
