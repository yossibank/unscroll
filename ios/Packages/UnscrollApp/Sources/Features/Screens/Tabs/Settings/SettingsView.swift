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
                if !model.isReady {
                    setupSection
                }

                companionSection

                blockedAppsSection

                difficultySection

                #if DEBUG
                prototypeSection
                #endif
            }
            .scrollContentBackground(.hidden)
            .background(Palette.paper)
            .navigationTitle("設定")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .companion:
                    CompanionPickerView(
                        model: model.makeCompanionPicker(),
                        isFirstTime: false,
                        onSaved: {
                            model.refresh()
                        }
                    )

                case .blockedApps:
                    BlockedAppsView(model: model)
                }
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
        case blockedApps
    }
}

private extension SettingsView {
    var setupSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Label("旅で止めるには準備が要ります", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(Palette.ink)
                    .symbolRenderingMode(.multicolor)

                Text("2 つそろうと、旅の間だけ選んだアプリを止めます")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
            }
            .padding(.vertical, 4)

            setupStep(number: 1, title: "Screen Time を許可する", isDone: model.isAuthorized) {
                Button("許可する") {
                    Task {
                        await model.requestAuthorization()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }

            NavigationLink(value: Route.blockedApps) {
                setupStep(number: 2, title: "止めるアプリを選ぶ", isDone: model.hasSelection) {
                    EmptyView()
                }
            }
        }
        .listRowBackground(Palette.coral.opacity(0.16))
    }

    var companionSection: some View {
        Section("相棒") {
            NavigationLink(value: Route.companion) {
                HStack(spacing: Spacing.medium) {
                    if let companion = model.companion {
                        CompanionSticker(
                            companion: companion,
                            pose: .walk,
                            size: 48,
                            breathes: false
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(companion.name)
                                .font(.headline)
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
        .listRowBackground(Palette.card)
    }

    var blockedAppsSection: some View {
        Section("止めるアプリ") {
            NavigationLink(value: Route.blockedApps) {
                LabeledContent("止めるアプリ", value: model.selectionSummary)
            }

            LabeledContent("Screen Time の許可") {
                if model.isAuthorized {
                    Label("許可あり", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Palette.teal)
                } else {
                    Button("許可する") {
                        Task {
                            await model.requestAuthorization()
                        }
                    }
                }
            }
        }
        .listRowBackground(Palette.card)
    }

    var difficultySection: some View {
        Section {
            Picker("外しにくさ", selection: $model.strictness) {
                ForEach(Strictness.allCases, id: \.self) { strictness in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title(for: strictness))
                                .foregroundStyle(Palette.ink)

                            Text(detail(for: strictness))
                                .font(.caption)
                                .foregroundStyle(Palette.muted)
                        }
                    } icon: {
                        Image(systemName: symbol(for: strictness))
                            .foregroundStyle(Palette.teal)
                    }
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
            .disabled(model.isTripActive)
        } header: {
            Text("外しにくさ")
        } footer: {
            if model.isTripActive {
                Text("旅が終わったら変えられます")
            }
        }
        .listRowBackground(Palette.card)
    }

    #if DEBUG
    var prototypeSection: some View {
        Section("試作の記録（開発の版だけ）") {
            Button("区切りの見張りを始める") {
                model.startUsageWatch()
            }
            .disabled(!model.isReady)

            NavigationLink {
                EventLogView(model: model)
            } label: {
                LabeledContent("記録を見る", value: "\(model.logLines.count) 行")
            }
        }
        .listRowBackground(Palette.card)
    }
    #endif

    func setupStep(
        number: Int,
        title: String,
        isDone: Bool,
        @ViewBuilder action: () -> some View
    ) -> some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "\(number).circle")
                .font(.title3)
                .foregroundStyle(isDone ? Palette.teal : Palette.ink)

            Text(title)
                .foregroundStyle(isDone ? Palette.muted : Palette.ink)
                .strikethrough(isDone)

            Spacer()

            if !isDone {
                action()
            }
        }
    }
}

private extension SettingsView {
    func title(for strictness: Strictness) -> String {
        switch strictness {
        case .gentle: "やさしい"
        case .normal: "ふつう"
        case .strict: "きびしい"
        }
    }

    func detail(for strictness: Strictness) -> String {
        switch strictness {
        case .gentle: "止めたアプリを 1 分だけ開ける"
        case .normal: "10 秒待つと開ける"
        case .strict: "旅が終わるまで開けない"
        }
    }

    func symbol(for strictness: Strictness) -> String {
        switch strictness {
        case .gentle: "leaf"
        case .normal: "hourglass"
        case .strict: "lock"
        }
    }
}
