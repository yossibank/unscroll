import Core
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
            .navigationDestination(for: Route.self) { _ in
                CompanionPickerView(
                    model: model.makeCompanionPicker(),
                    isFirstTime: false,
                    onSaved: {
                        model.refresh()
                    }
                )
            }
            .tint(Palette.teal)
            .onAppear {
                model.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                model.refresh()
            }
        }
    }
}

private extension SettingsView {
    enum Route: Hashable {
        case companion
    }
}

private extension SettingsView {
    var isReady: Bool {
        model.isAuthorized && !BlockedApps.isEmpty(model.selection)
    }

    var companionSection: some View {
        Section("相棒") {
            NavigationLink(value: Route.companion) {
                HStack(spacing: Spacing.small + 4) {
                    if let companion = model.companion {
                        CompanionSticker(
                            companion: companion,
                            pose: .walk,
                            size: 40,
                            breathes: false
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(companion.name)
                                .foregroundStyle(Palette.ink)

                            Text(companion.kindLabel)
                                .font(.caption)
                                .foregroundStyle(Palette.muted)
                        }
                    } else {
                        Text("相棒を選ぶ")
                    }
                }
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
