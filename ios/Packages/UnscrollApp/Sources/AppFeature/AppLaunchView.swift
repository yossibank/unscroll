import Core
import DesignSystem
import SwiftUI

struct AppLaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var pose = Companion.Pose.sleep
    @State private var dawn = 0.0
    @State private var travel: CGFloat = 0
    @State private var lift: CGFloat = 0
    @State private var holdsBag = false
    @State private var hasDeparted = false
    @State private var reveal: CGFloat = 0
    @State private var isLeaving = false

    let companion: Companion?
    let isReady: Bool
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let center = LaunchScenery.sunCenter(in: size)
            let reach = hypot(size.width / 2, max(center.y, size.height - center.y)) * 2.1

            ZStack {
                LaunchScenery(
                    companion: traveler,
                    pose: pose,
                    dawn: dawn,
                    travel: travel,
                    lift: lift,
                    holdsBag: holdsBag
                )

                Palette.paper
                    .mask {
                        Circle()
                            .frame(width: reach * reveal, height: reach * reveal)
                            .position(center)
                    }
            }
        }
        .ignoresSafeArea()
        .opacity(isLeaving ? 0 : 1)
        .allowsHitTesting(!isLeaving)
        .accessibilityHidden(true)
        .task(id: isReady) {
            guard isReady else {
                return
            }

            await depart()
        }
        .onChange(of: hasDeparted) {
            open()
        }
    }
}

private extension AppLaunchView {
    var traveler: Companion? {
        isReady ? companion ?? .starter : nil
    }

    func depart() async {
        guard !reduceMotion else {
            dawn = 2
            pose = .jump
            holdsBag = true

            try? await Task.sleep(for: .milliseconds(500))

            hasDeparted = true
            return
        }

        try? await Task.sleep(for: .milliseconds(350))

        pose = .blink

        withAnimation(.easeInOut(duration: 0.35)) {
            dawn = 1
        }

        try? await Task.sleep(for: .milliseconds(350))

        pose = .jump
        holdsBag = true

        withAnimation(.easeInOut(duration: 0.3)) {
            dawn = 2
        }

        withAnimation(.easeOut(duration: 0.15)) {
            lift = 0.14
        }

        try? await Task.sleep(for: .milliseconds(150))

        withAnimation(.easeIn(duration: 0.15)) {
            lift = 0
        }

        try? await Task.sleep(for: .milliseconds(250))

        pose = .walk

        withAnimation(.easeIn(duration: 0.5)) {
            travel = 1
        }

        try? await Task.sleep(for: .milliseconds(500))

        hasDeparted = true
    }

    func open() {
        guard !reduceMotion else {
            leave()
            return
        }

        withAnimation(.easeIn(duration: 0.3)) {
            reveal = 1
        } completion: {
            leave()
        }
    }

    func leave() {
        withAnimation(.easeOut(duration: 0.2)) {
            isLeaving = true
        } completion: {
            onFinish()
        }
    }
}

#Preview {
    AppLaunchView(companion: nil, isReady: true) {}
}
