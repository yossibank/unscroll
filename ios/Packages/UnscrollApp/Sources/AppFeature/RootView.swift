import FeatureModels
import Features
import SwiftUI

public struct RootView: View {
    @State private var model = AppModel {
        try ScreenParts.appGroup(clock: .system)
    }

    @State private var isLaunching = true

    public init() {}

    public var body: some View {
        ZStack {
            content

            if isLaunching {
                AppLaunchView(companion: model.state.companion, isReady: isReady) {
                    isLaunching = false
                }
            }
        }
        .task {
            model.open()
        }
        .onReceive(NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                model.suspend()
        }
        .onReceive(NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                model.resume()
        }
    }
}

private extension RootView {
    var isReady: Bool {
        if case .opening = model.state.launch {
            return false
        }

        return true
    }

    @ViewBuilder
    var content: some View {
        switch model.state.launch {
        case .opening:
            ProgressView()

        case let .ready(parts):
            MainView(
                parts: parts,
                isRevealed: !isLaunching
            )

        case let .failed(message):
            ContentUnavailableView(
                "DB を開けない",
                systemImage: "externaldrive.badge.xmark",
                description: Text(message)
            )
        }
    }
}
