import Core
import DesignSystem
import SwiftUI

public struct RoomView: View {
    @State private var model: RoomModel
    @State private var settings: SettingsModel
    @State private var isTripCoverShown = false
    @State private var isDecorShown = false
    @State private var pose = Companion.Pose.walk
    @State private var pokes = 0

    @Environment(\.scenePhase) private var scenePhase

    public init(
        model: RoomModel,
        settings: SettingsModel
    ) {
        _model = State(initialValue: model)
        _settings = State(initialValue: settings)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                topBar

                RoomPhoto(model: model, pose: pose) {
                    poke()
                }

                appSets

                RoomTicket(model: model)

                usageCard
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.small)
            .padding(.bottom, FloatingTabBarMetrics.clearance)
        }
        .background(PaperBackdrop())
        .onAppear {
            model.refresh()
            settings.refresh()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            model.refresh()
            settings.refresh()
        }
        .onChange(of: model.progress?.activeTrip == nil) {
            settings.refresh()
        }
        .task {
            await blink()
        }
        .task(id: pokes) {
            await settleAfterPoke()
        }
        .fullScreenCover(
            isPresented: tripBinding,
            onDismiss: {
                isTripCoverShown = false
            },
            content: {
                TripView(model: model)
                    .onAppear {
                        isTripCoverShown = true
                    }
            }
        )
        .sheet(
            item: finishedTripBinding,
            onDismiss: {
                model.acknowledgeFinishedTrip()
            },
            content: { trip in
                TripResultSheet(
                    trip: trip,
                    model: model,
                    onClose: {
                        model.acknowledgeFinishedTrip()
                    }
                )
            }
        )
        .sheet(isPresented: $isDecorShown) {
            RoomDecorSheet(model: model) {
                isDecorShown = false
            }
            .presentationDetents([.medium, .large])
        }
    }
}

private extension RoomView {
    var topBar: some View {
        HStack(spacing: Spacing.small) {
            TagPill(
                model.journey.name,
                systemImage: "map.fill",
                tint: Palette.tealDeep,
                wash: Palette.tealSoft
            )

            TagPill(
                postcardCount,
                systemImage: "envelope.fill",
                tint: Palette.coralDeep,
                wash: Palette.coralSoft
            )

            Spacer(minLength: 0)

            Button {
                isDecorShown = true
            } label: {
                TagPill(
                    "模様替え",
                    systemImage: "paintbrush.fill",
                    tint: Palette.plumDeep,
                    wash: Palette.plumSoft
                )
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44)
        }
    }

    var usageCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            CardLabel(
                "今日のスマホ",
                systemImage: "iphone",
                tint: Palette.skyDeep,
                wash: Palette.skySoft
            )

            UsageReportView()
                .id(settings.isAuthorized)
                .frame(height: 792)
        }
        .roundedCard()
    }

    var appSets: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label("止めるもの", systemImage: "hand.raised.fill")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 4)

            AppSetTags(model: settings, hidesEmpty: true) {
                model.refresh()
            }
            .disabled(isOnTrip)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension RoomView {
    var postcardCount: String {
        let total = model.journey.landmarks.count - 1
        return "\(model.arrivals.count) / \(total) 枚"
    }

    var tripBinding: Binding<Bool> {
        Binding(
            get: { model.progress?.activeTrip != nil },
            set: { _ in }
        )
    }

    var finishedTripBinding: Binding<Trip?> {
        Binding(
            get: { canShowResult ? model.finishedTrip : nil },
            set: { _ in }
        )
    }

    var isOnTrip: Bool {
        model.progress?.activeTrip != nil
    }

    var canShowResult: Bool {
        model.progress?.activeTrip == nil && !isTripCoverShown
    }

    func poke() {
        pose = .joy
        pokes += 1
    }

    func settleAfterPoke() async {
        guard pokes > 0 else {
            return
        }

        try? await Task.sleep(for: .milliseconds(800))

        if !Task.isCancelled {
            pose = .walk
        }
    }

    func blink() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(3200))

            guard pose == .walk else {
                continue
            }

            pose = .blink
            try? await Task.sleep(for: .milliseconds(160))

            if pose == .blink {
                pose = .walk
            }
        }
    }
}
