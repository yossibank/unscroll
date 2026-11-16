import SwiftUI

public extension View {
    func hop(
        trigger: some Equatable,
        height: CGFloat = 10
    ) -> some View {
        modifier(Hop(trigger: trigger, height: height))
    }
}

private struct Hop<Trigger: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let trigger: Trigger
    let height: CGFloat

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content
                .keyframeAnimator(initialValue: HopFrame(), trigger: trigger) { view, frame in
                    view
                        .scaleEffect(x: frame.width, y: frame.height, anchor: .bottom)
                        .offset(y: frame.lift)
                } keyframes: { _ in
                    KeyframeTrack(\.width) {
                        CubicKeyframe(1.12, duration: 0.1)
                        SpringKeyframe(0.94, duration: 0.16)
                        SpringKeyframe(1, duration: 0.34, spring: .bouncy)
                    }

                    KeyframeTrack(\.height) {
                        CubicKeyframe(0.86, duration: 0.1)
                        SpringKeyframe(1.1, duration: 0.16)
                        SpringKeyframe(1, duration: 0.34, spring: .bouncy)
                    }

                    KeyframeTrack(\.lift) {
                        CubicKeyframe(0, duration: 0.1)
                        SpringKeyframe(-height, duration: 0.16)
                        SpringKeyframe(0, duration: 0.34, spring: .bouncy)
                    }
                }
        }
    }
}

private struct HopFrame {
    var width: CGFloat = 1
    var height: CGFloat = 1
    var lift: CGFloat = 0
}

#Preview {
    @Previewable @State var hops = 0

    Button("跳ねる") {
        hops += 1
    }
    .buttonStyle(.borderedProminent)
    .hop(trigger: hops)
    .padding(40)
}
