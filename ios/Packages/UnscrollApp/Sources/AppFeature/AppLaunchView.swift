import Core
import DesignSystem
import SwiftUI

struct AppLaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var pose = Companion.Pose.walk
    @State private var dawn = 0.0
    @State private var hasGreeted = false
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
                    companion: shownCompanion,
                    pose: pose,
                    dawn: dawn
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

            await greet()
        }
        .onChange(of: hasGreeted) {
            open()
        }
    }
}

private extension AppLaunchView {
    var shownCompanion: Companion? {
        isReady ? companion ?? .starter : nil
    }

    func greet() async {
        guard !reduceMotion else {
            dawn = 2
            pose = .wave

            try? await Task.sleep(for: .milliseconds(400))

            hasGreeted = true
            return
        }

        try? await Task.sleep(for: .milliseconds(100))

        pose = .jump

        withAnimation(.easeInOut(duration: 0.5)) {
            dawn = 2
        }

        try? await Task.sleep(for: .milliseconds(350))

        pose = .wave

        try? await Task.sleep(for: .milliseconds(300))

        hasGreeted = true
    }

    func open() {
        guard !reduceMotion else {
            leave()
            return
        }

        withAnimation(.easeIn(duration: 0.25)) {
            reveal = 1
        } completion: {
            leave()
        }
    }

    func leave() {
        withAnimation(.easeOut(duration: 0.15)) {
            isLeaving = true
        } completion: {
            onFinish()
        }
    }
}

#Preview {
    AppLaunchView(companion: nil, isReady: true) {}
}
