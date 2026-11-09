import Features
import Store
import SwiftUI

public struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var phase = Phase.loading

    public init() {}

    public var body: some View {
        content
            .task {
                openDatabase()
            }
            .onChange(of: scenePhase) {
                followScenePhase()
            }
    }
}

private extension RootView {
    enum Phase {
        case loading
        case ready(FocusPrototypeModel)
        case failed(String)
    }
}

private extension RootView {
    @ViewBuilder
    var content: some View {
        switch phase {
        case .loading:
            ProgressView()

        case let .ready(model):
            FocusPrototypeView(model: model)

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
            phase = .ready(FocusPrototypeModel(database: database))
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func followScenePhase() {
        switch scenePhase {
        case .background:
            AppDatabase.suspend()

        case .active:
            AppDatabase.resume()

        default:
            break
        }
    }
}
