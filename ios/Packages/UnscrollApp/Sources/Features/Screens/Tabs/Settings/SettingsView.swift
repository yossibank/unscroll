import Core
import DesignSystem
import SwiftUI

public struct SettingsView: View {
    @State private var model: SettingsModel
    @State private var path: [Route] = []

    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.tabBarHidden) private var tabBarHidden

    public init(model: SettingsModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium + 4) {
                    JournalTitle("旅の支度", note: "出かける前に、ととのえましょう")

                    if !model.isReady {
                        setupCard
                    }

                    NavigationLink(value: Route.companion) {
                        SettingsPassport(
                            companion: model.companion,
                            kilometers: model.kilometersTogether
                        )
                    }
                    .buttonStyle(.plain)

                    blockedAppsPage

                    strictnessPage

                    aboutPage

                    Text("おるすマホ \(SettingsLink.appVersion)")
                        .font(.caption2.weight(.medium))
                        .monospacedDigit()
                        .foregroundStyle(Palette.muted)
                        .frame(maxWidth: .infinity)

                    #if DEBUG
                    prototypePage
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
                title: "スクリーンタイムを許可する",
                isDone: model.isAuthorized,
                actionTitle: "許可する",
                isLoading: model.isRequestingAuthorization
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

    var blockedAppsPage: some View {
        SettingsPage("旅で止めるもの", tint: Palette.coral) {
            NavigationLink(value: Route.blockedApps) {
                SettingsRow(
                    title: "止めるアプリ",
                    detail: model.selectionSummary,
                    systemImage: "hand.raised.fill",
                    tint: Palette.coral
                ) {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.heavy))
                        .foregroundStyle(Palette.muted.opacity(0.6))
                }
            }
            .buttonStyle(.plain)

            SettingsRule()

            SettingsRow(title: "スクリーンタイムの許可", systemImage: "hourglass", tint: Palette.sky) {
                if model.isAuthorized {
                    Label("許可あり", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Palette.teal)
                } else if model.isRequestingAuthorization {
                    ProgressView()
                        .tint(Palette.teal)
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
    }

    var strictnessPage: some View {
        let opacity = model.isTripActive ? 0.5 : 1

        return SettingsPage("外しにくさ", tint: Palette.sun) {
            SettingsStrictness(strictness: $model.strictness, companion: model.companion)
                .padding(.top, 4)
                .disabled(model.isTripActive)
                .opacity(opacity)

            if model.isTripActive {
                Text("旅が終わったら変えられます")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .padding(.horizontal, Spacing.small)
                    .padding(.top, 4)
            }
        }
    }

    var aboutPage: some View {
        SettingsPage("このアプリについて", tint: Palette.teal) {
            Button {
                open(SettingsLink.contact())
            } label: {
                SettingsRow(title: "お問い合わせ", systemImage: "envelope.fill", tint: Palette.teal) {
                    outLink
                }
            }
            .buttonStyle(.plain)

            SettingsRule()

            Button {
                open(SettingsLink.review)
            } label: {
                SettingsRow(title: "レビューを書く", systemImage: "star.fill", tint: Palette.sun) {
                    outLink
                }
            }
            .buttonStyle(.plain)
        }
    }

    var outLink: some View {
        Image(systemName: "arrow.up.right")
            .font(.footnote.weight(.heavy))
            .foregroundStyle(Palette.muted.opacity(0.6))
    }

    #if DEBUG
    var prototypePage: some View {
        SettingsPage("試作の記録（開発の版だけ）", tint: Palette.muted) {
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

            SettingsRule()

            NavigationLink {
                EventLogView(model: model)
            } label: {
                SettingsRow(title: "記録を見る", systemImage: "list.bullet", tint: Palette.muted) {
                    Text("\(model.logLines.count) 行")
                }
            }
            .buttonStyle(.plain)
        }
    }
    #endif

    func setupStep(
        number: Int,
        title: String,
        isDone: Bool,
        actionTitle: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        let mark = isDone ? "✓" : "\(number)"
        let markFill = isDone ? Palette.teal : Palette.coral
        let titleInk = isDone ? Palette.muted : Palette.ink

        return HStack(spacing: Spacing.small + 4) {
            Text(mark)
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(markFill, in: Circle())

            Text(title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(titleInk)
                .strikethrough(isDone)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if !isDone {
                Button(action: action) {
                    HStack(spacing: 4) {
                        if isLoading {
                            ProgressView()
                                .controlSize(.mini)
                                .tint(.white)
                        }

                        Text(actionTitle)
                    }
                }
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, Spacing.small + 4)
                .padding(.vertical, Spacing.small)
                .background(Palette.coral, in: Capsule())
                .buttonStyle(.plain)
                .allowsHitTesting(!isLoading)
            }
        }
        .padding(Spacing.small + 4)
        .background(.white, in: .rect(cornerRadius: 20))
    }
}

private extension SettingsView {
    func open(_ url: URL?) {
        guard let url else {
            return
        }

        openURL(url)
    }
}
