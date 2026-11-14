import Features
import Store
import SwiftUI

public struct RootView: View {
    @State private var phase = Phase.loading

    public init() {}

    public var body: some View {
        content
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
    @ViewBuilder
    var content: some View {
        switch phase {
        case .loading:
            ProgressView()

        case let .ready(database):
            MainView(database: database)

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
            phase = .ready(database)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
