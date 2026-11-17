import Core
import DesignSystem
import FamilyControls
import SwiftUI

public struct OnboardingView: View {
    @State private var model: OnboardingModel
    @State private var isForward = true
    @State private var isPickerPresented = false

    private let onFinish: () -> Void

    public init(
        model: OnboardingModel,
        onFinish: @escaping () -> Void
    ) {
        _model = State(initialValue: model)

        self.onFinish = onFinish
    }

    public var body: some View {
        @Bindable var settings = model.settings

        VStack(spacing: Spacing.medium) {
            topBar

            ZStack {
                page
                    .id(model.page)
                    .transition(pageTransition)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .contentShape(.rect)
            .gesture(swipe)

            bottomButtons
        }
        .padding(.horizontal, Spacing.medium + 4)
        .padding(.top, Spacing.small)
        .padding(.bottom, Spacing.small)
        .background(PaperBackdrop())
        .sensoryFeedback(.selection, trigger: model.page)
        .familyActivityPicker(
            isPresented: $isPickerPresented,
            selection: $settings.selection
        )
        .onChange(of: settings.selection) {
            settings.saveSelection()
        }
    }
}

private extension OnboardingView {
    var topBar: some View {
        let skipOpacity = model.canSkipIntro ? 1.0 : 0

        return HStack {
            if model.canGoBack {
                Button {
                    turn(forward: false)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Palette.muted)
                        .frame(width: 40, height: 40)
                        .background(Palette.card, in: Circle())
                        .shadow(color: Palette.shadow, radius: 4, y: 2)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("戻る")
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }

            Spacer()

            if let step = model.setupStep {
                Text("旅の支度 \(step) / \(OnboardingModel.setupPages.count)")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.sunDeep)
                    .padding(.horizontal, Spacing.small + 4)
                    .padding(.vertical, 4)
                    .background(Palette.sunSoft, in: Capsule())
            } else {
                dots
            }

            Spacer()

            Button("とばす") {
                skipIntro()
            }
            .font(.footnote.weight(.heavy))
            .foregroundStyle(Palette.muted)
            .frame(width: 64, height: 44, alignment: .trailing)
            .opacity(skipOpacity)
            .disabled(!model.canSkipIntro)
        }
    }

    var dots: some View {
        HStack(spacing: 6) {
            ForEach(OnboardingModel.introPages, id: \.self) { item in
                let isCurrent = item == model.page
                let width: CGFloat = isCurrent ? 22 : 7
                let fill = isCurrent ? Palette.teal : Palette.floorEdge.opacity(0.5)

                Capsule()
                    .fill(fill)
                    .frame(width: width, height: 7)
            }
        }
        .animation(.snappy, value: model.page)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(dotsLabel)
    }

    @ViewBuilder
    var page: some View {
        switch model.page {
        case .companion:
            companionPage

        case .permission:
            permissionPage

        case .apps:
            appsPage

        default:
            OnboardingIntro(page: model.page)
        }
    }

    var companionPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                JournalTitle("いっしょに旅する相棒", note: "あとから設定で変えられます")

                SettingsPassport(companion: model.companion.preview, kilometers: nil)

                CompanionPickerForm(model: model.companion)
            }
            .padding(.bottom, Spacing.medium)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }

    var permissionPage: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            JournalTitle("Screen Time の許可", note: "旅の間だけ、アプリを止めるために使います")

            SettingsPage("Screen Time で使うこと", tint: Palette.sky) {
                Image(systemName: model.settings.isAuthorized ? "checkmark" : "hourglass")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 96)
                    .background(Palette.sky, in: .rect(cornerRadius: 28))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.small)
                    .accessibilityHidden(true)

                promise("止めるのは、旅に出ている間だけです")

                SettingsRule()

                promise("使った時間やアプリの名前は、この端末の外に出ません")

                SettingsRule()

                promise("許可は、iPhone の設定からいつでも外せます")
            }
        }
    }

    var appsPage: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            JournalTitle("旅で止めるアプリ", note: "つい開いてしまうものを選びます")

            SettingsPage("旅で止めるもの", tint: Palette.coral) {
                Button {
                    isPickerPresented = true
                } label: {
                    SettingsRow(
                        title: "止めるアプリを選ぶ",
                        detail: model.settings.selectionSummary,
                        systemImage: "hand.raised.fill",
                        tint: Palette.coral
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.heavy))
                            .foregroundStyle(Palette.muted.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                .disabled(!model.settings.isAuthorized)

                if !model.settings.isAuthorized {
                    Text("Screen Time を許可すると選べます")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.muted)
                        .padding(.horizontal, Spacing.small)
                }
            }

            TapedPhoto(caption: waitingCaption, tilt: -1.5) {
                RoomScene(
                    companion: model.settings.companion,
                    look: RoomLook(defaults: .standard),
                    pose: .wave,
                    window: Journey.tokyoToKyoto.nextLandmark(after: 0),
                    postcards: [],
                    nextRemaining: nil,
                    souvenirs: [],
                    onPoke: {}
                )
                .allowsHitTesting(false)
            }
            .padding(.horizontal, Spacing.large)
            .accessibilityHidden(true)
        }
    }

    var bottomButtons: some View {
        let laterOpacity = showsLater ? 1.0 : 0

        return VStack(spacing: 4) {
            Button(primaryTitle) {
                primaryAction()
            }
            .buttonStyle(.pill)
            .disabled(!canPrimary)

            Button("あとで設定する") {
                laterAction()
            }
            .font(.footnote.weight(.heavy))
            .foregroundStyle(Palette.muted)
            .frame(minHeight: 44)
            .opacity(laterOpacity)
            .disabled(!showsLater)
        }
    }

    func promise(_ text: String) -> some View {
        Label {
            Text(text)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: "checkmark")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Palette.teal, in: .rect(cornerRadius: 8))
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.small)
    }
}

private extension OnboardingView {
    var pageTransition: AnyTransition {
        let insertion: Edge = isForward ? .trailing : .leading
        let removal: Edge = isForward ? .leading : .trailing

        return .asymmetric(
            insertion: .move(edge: insertion).combined(with: .opacity),
            removal: .move(edge: removal).combined(with: .opacity)
        )
    }

    var swipe: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let width = value.translation.width

                guard abs(width) > abs(value.translation.height) else {
                    return
                }

                if width < -60, model.canSwipeForward {
                    turn(forward: true)
                } else if width > 60, model.canGoBack {
                    turn(forward: false)
                }
            }
    }

    var dotsLabel: String {
        let index = (OnboardingModel.introPages.firstIndex(of: model.page) ?? 0) + 1
        return "説明 \(index) / \(OnboardingModel.introPages.count)"
    }

    var waitingCaption: String {
        guard let companion = model.settings.companion else {
            return "相棒が、出発を待っています"
        }

        return "\(companion.name)が、出発を待っています"
    }

    var primaryTitle: String {
        switch model.page {
        case .usage: "旅の支度をする"
        case .permission: model.settings.isAuthorized ? "次へ" : "許可する"
        case .apps: "旅をはじめる"
        default: "次へ"
        }
    }

    var canPrimary: Bool {
        switch model.page {
        case .companion: model.companion.draft != nil
        case .permission: !model.isRequesting
        default: true
        }
    }

    var showsLater: Bool {
        switch model.page {
        case .permission: !model.settings.isAuthorized
        case .apps: !model.settings.hasSelection
        default: false
        }
    }

    func primaryAction() {
        switch model.page {
        case .companion:
            withAnimation(.snappy) {
                isForward = true
                model.saveCompanion()
            }

        case .permission where !model.settings.isAuthorized:
            Task {
                if await model.requestAuthorization() {
                    turn(forward: true)
                }
            }

        case .apps:
            finish()

        default:
            turn(forward: true)
        }
    }

    func laterAction() {
        if model.page == .apps {
            finish()
        } else {
            turn(forward: true)
        }
    }

    func finish() {
        model.complete()
        onFinish()
    }

    func turn(forward: Bool) {
        withAnimation(.snappy) {
            isForward = forward

            if forward {
                model.next()
            } else {
                model.back()
            }
        }
    }

    func skipIntro() {
        withAnimation(.snappy) {
            isForward = true
            model.skipIntro()
        }
    }
}
