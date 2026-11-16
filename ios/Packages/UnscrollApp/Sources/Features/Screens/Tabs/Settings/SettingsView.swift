import Core
import DesignSystem
import SwiftUI

public struct SettingsView: View {
    @State private var model: SettingsModel
    @State private var path: [Route] = []

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.tabBarHidden) private var tabBarHidden

    public init(model: SettingsModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    if !model.isReady {
                        setupCard
                    }

                    companionCard

                    blockedAppsCard

                    difficultyCard

                    #if DEBUG
                    prototypeCard
                    #endif
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.small)
                .padding(.bottom, FloatingTabBarMetrics.clearance)
            }
            .background(PaperBackdrop())
            .toolbarVisibility(.hidden, for: .navigationBar)
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
            .onAppear {
                model.refresh()
            }
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                model.refresh()
            }
            .onChange(of: path.isEmpty) { _, isEmpty in
                tabBarHidden.wrappedValue = !isEmpty
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
    var setupCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            VStack(alignment: .leading, spacing: 4) {
                Label("旅で止めるには、準備が要ります", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Palette.coralDeep)

                Text("2 つそろうと、旅の間だけ選んだアプリを止めます")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }

            setupStep(
                number: 1,
                title: "Screen Time を許可する",
                isDone: model.isAuthorized,
                actionTitle: "許可する"
            ) {
                Task {
                    await model.requestAuthorization()
                }
            }

            setupStep(
                number: 2,
                title: "止めるアプリを選ぶ",
                isDone: model.hasSelection,
                actionTitle: "選ぶ"
            ) {
                path.append(.blockedApps)
            }
        }
        .roundedCard(fill: LinearGradient(
            colors: [Palette.coralSoft, Palette.card],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }

    var companionCard: some View {
        NavigationLink(value: Route.companion) {
            HStack(spacing: Spacing.medium) {
                Group {
                    if let companion = model.companion {
                        CompanionSticker(
                            companion: companion,
                            pose: .walk,
                            size: 48,
                            breathes: false
                        )
                    } else {
                        Image(systemName: "pawprint.fill")
                            .font(.title2)
                            .foregroundStyle(Palette.sunDeep)
                    }
                }
                .frame(width: 64, height: 64)
                .background(Palette.sunSoft, in: .rect(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text("いっしょに旅する相棒")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Palette.teal)

                    Text(model.companion?.name ?? "相棒を選ぶ")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if let companion = model.companion {
                        Text(companion.kindLabel)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Palette.muted)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(Palette.muted.opacity(0.6))
            }
            .roundedCard(fill: LinearGradient(
                colors: [Palette.tealSoft, Palette.card],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
        .buttonStyle(.plain)
    }

    var blockedAppsCard: some View {
        VStack(spacing: 0) {
            NavigationLink(value: Route.blockedApps) {
                SettingsRow(title: "止めるアプリ", systemImage: "hand.raised.fill", tint: Palette.coral) {
                    Text(model.selectionSummary)

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.heavy))
                        .foregroundStyle(Palette.muted.opacity(0.6))
                }
            }
            .buttonStyle(.plain)

            Divider()
                .overlay(Palette.paperDeep)

            SettingsRow(title: "Screen Time の許可", systemImage: "hourglass", tint: Palette.sky) {
                if model.isAuthorized {
                    Label("許可あり", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Palette.teal)
                } else {
                    Button("許可する") {
                        Task {
                            await model.requestAuthorization()
                        }
                    }
                    .foregroundStyle(Palette.teal)
                }
            }
        }
        .roundedCard(padding: Spacing.small)
    }

    var difficultyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("外しにくさ")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, Spacing.small)

            VStack(spacing: 0) {
                ForEach(Strictness.allCases, id: \.self) { strictness in
                    if strictness != Strictness.allCases.first {
                        Divider()
                            .overlay(Palette.paperDeep)
                    }

                    strictnessRow(strictness)
                }
            }
            .roundedCard(padding: Spacing.small)
            .disabled(model.isTripActive)

            if model.isTripActive {
                Text("旅が終わったら変えられます")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .padding(.horizontal, Spacing.small)
            }
        }
    }

    #if DEBUG
    var prototypeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("試作の記録（開発の版だけ）")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, Spacing.small)

            VStack(spacing: 0) {
                Button {
                    model.startUsageWatch()
                } label: {
                    SettingsRow(
                        title: "区切りの見張りを始める",
                        systemImage: "eye.fill",
                        tint: Palette.muted
                    ) {
                        EmptyView()
                    }
                }
                .buttonStyle(.plain)
                .disabled(!model.isReady)

                Divider()
                    .overlay(Palette.paperDeep)

                NavigationLink {
                    EventLogView(model: model)
                } label: {
                    SettingsRow(title: "記録を見る", systemImage: "list.bullet", tint: Palette.muted) {
                        Text("\(model.logLines.count) 行")
                    }
                }
                .buttonStyle(.plain)
            }
            .roundedCard(padding: Spacing.small)
        }
    }
    #endif

    func strictnessRow(_ strictness: Strictness) -> some View {
        let isSelected = model.strictness == strictness

        return Button {
            model.strictness = strictness
        } label: {
            SettingsRow(
                title: title(for: strictness),
                detail: detail(for: strictness),
                systemImage: symbol(for: strictness),
                tint: tint(for: strictness)
            ) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Palette.teal, in: Circle())
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func setupStep(
        number: Int,
        title: String,
        isDone: Bool,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: Spacing.small + 4) {
            Text(isDone ? "✓" : "\(number)")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(isDone ? Palette.teal : Palette.coral, in: Circle())

            Text(title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(isDone ? Palette.muted : Palette.ink)
                .strikethrough(isDone)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if !isDone {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.small + 4)
                    .padding(.vertical, Spacing.small)
                    .background(Palette.coral, in: Capsule())
                    .buttonStyle(.plain)
            }
        }
        .padding(Spacing.small + 4)
        .background(.white, in: .rect(cornerRadius: 20))
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
        case .gentle: "leaf.fill"
        case .normal: "hourglass"
        case .strict: "lock.fill"
        }
    }

    func tint(for strictness: Strictness) -> Color {
        switch strictness {
        case .gentle: Palette.leaf
        case .normal: Palette.sun
        case .strict: Palette.plum
        }
    }
}
