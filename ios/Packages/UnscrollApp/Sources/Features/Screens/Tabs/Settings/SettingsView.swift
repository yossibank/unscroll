import DesignSystem
import SwiftUI

public struct SettingsView: View {
    @State private var model: SettingsModel

    @Environment(\.scenePhase) private var scenePhase

    public init(model: SettingsModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            Form {
                companionSection

                blockedAppsSection

                difficultySection

                prototypeSection
            }
            .navigationTitle("設定")
            .tint(Palette.teal)
            .onAppear {
                model.refresh()
            }
            .onChange(of: scenePhase) {
                model.refresh()
            }
        }
    }
}

private extension SettingsView {
    var isReady: Bool {
        model.isAuthorized && !BlockedApps.isEmpty(model.selection)
    }

    var companionSection: some View {
        Section("相棒") {
            HStack {
                Text("フェネックの ふく")

                Spacer()

                ProvisionalMark()
            }
        }
    }

    var blockedAppsSection: some View {
        Section("止めるアプリ") {
            NavigationLink {
                BlockedAppsView(model: model)
            } label: {
                LabeledContent("止めるアプリ", value: model.selectionSummary)
            }

            LabeledContent("Screen Time の許可") {
                if model.isAuthorized {
                    Text("許可あり")
                } else {
                    Button("許可する") {
                        Task {
                            await model.requestAuthorization()
                        }
                    }
                }
            }
        }
    }

    var difficultySection: some View {
        Section("外しにくさ") {
            HStack {
                Text("ふつう（10 秒待つ）")

                Spacer()

                ProvisionalMark()
            }
        }
    }

    var prototypeSection: some View {
        Section("試作の記録（公開前に消す）") {
            Button("区切りの見張りを始める") {
                model.startUsageWatch()
            }
            .disabled(!isReady)

            NavigationLink {
                EventLogView(model: model)
            } label: {
                LabeledContent("記録を見る", value: "\(model.logLines.count) 行")
            }
        }
    }
}
