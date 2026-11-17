import Core
import Features
import Store
import SwiftUI

public struct RootView: View {
    @State private var phase = Phase.loading
    @State private var isLaunching = true
    @State private var launchCompanion: Companion?

    public init() {}

    public var body: some View {
        ZStack {
            content

            if isLaunching {
                AppLaunchView(companion: launchCompanion, isReady: isReady) {
                    isLaunching = false
                }
            }
        }
        .task {
            openDatabase()
        }
        .onReceive(NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                AppDatabase.suspend()
        }
        .onReceive(NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                AppDatabase.resume()
        }
    }
}

private extension RootView {
    enum Phase {
        case loading
        case ready(AppDatabase)
        case failed(String)
    }
}

private extension RootView {
    var isReady: Bool {
        if case .loading = phase {
            return false
        }

        return true
    }

    @ViewBuilder
    var content: some View {
        switch phase {
        case .loading:
            ProgressView()

        case let .ready(database):
            MainView(
                database: database,
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

    func openDatabase() {
        do {
            let database = try AppDatabase.appGroup()
            launchCompanion = try? database.companion()
            phase = .ready(database)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
