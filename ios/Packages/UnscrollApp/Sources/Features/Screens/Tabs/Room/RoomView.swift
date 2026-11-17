import Core
import DesignSystem
import SwiftUI

public struct RoomView: View {
    @State private var model: RoomModel
    @State private var isTripCoverShown = false
    @State private var isDecorShown = false
    @State private var pose = Companion.Pose.walk
    @State private var pokes = 0

    @Environment(\.scenePhase) private var scenePhase

    public init(model: RoomModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                topBar

                companionCard

                distanceCard

                RoomTripCard(model: model)

                usageCard
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.top, Spacing.small)
            .padding(.bottom, FloatingTabBarMetrics.clearance)
        }
        .background(PaperBackdrop())
        .onAppear {
            model.refresh()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            model.refresh()
        }
        .refreshable {
            model.refresh()
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
                .presentationDetents([.medium, .large])
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

    var companionCard: some View {
        scene
            .overlay {
                GeometryReader { proxy in
                    bubble
                        .position(x: proxy.size.width * 0.27, y: proxy.size.height * 0.5)
                }
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                if let companion = model.companion {
                    Text(companion.name)
                        .font(.footnote.weight(.heavy))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, Spacing.small + 4)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.92), in: Capsule())
                        .padding(Spacing.small + 4)
                        .allowsHitTesting(false)
                }
            }
            .clipShape(.rect(cornerRadius: RoundedCard.radius))
            .shadow(color: Palette.shadow, radius: 12, y: 8)
    }

    var scene: some View {
        RoomScene(
            companion: model.companion,
            look: model.look,
            pose: pose,
            window: model.nextLandmark ?? model.journey.landmarks.last,
            postcards: model.hungPostcards,
            nextRemaining: model.kilometersToNext,
            souvenirs: model.arrivals.map(\.landmark).filter { $0.souvenir != nil },
            onPoke: {
                poke()
            }
        )
    }

    var bubble: some View {
        Text(pose == .joy ? "うれしい！" : "そろそろ出かける？")
            .font(.caption2.weight(.heavy))
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, 4)
            .background(alignment: .bottomTrailing) {
                Image(systemName: "triangleshape.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(150))
                    .offset(x: 2, y: 4)
            }
            .background(.white, in: Capsule())
            .shadow(color: Palette.ink.opacity(0.12), radius: 4, y: 3)
            .contentTransition(.opacity)
            .animation(.snappy, value: pose == .joy)
    }

    var distanceCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            CardLabel(
                "進んだ距離",
                systemImage: "figure.walk",
                tint: Palette.teal,
                wash: Palette.tealSoft
            ) {
                Text(nextNote)
                    .foregroundStyle(Palette.teal)
            }

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(model.kilometers)")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(Palette.teal)
                    .contentTransition(.numericText())

                Text("/ \(model.journey.totalKilometers) km")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Palette.muted)
            }

            JourneyTrack(ratio: progressRatio)
                .padding(.top, 4)

            HStack {
                Text(model.journey.landmarks.first?.name ?? "")

                Spacer()

                Text(model.journey.landmarks.last?.name ?? "")
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(Palette.muted)
        }
        .roundedCard()
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
                .frame(height: 440)
        }
        .roundedCard()
    }
}

private extension RoomView {
    var postcardCount: String {
        let total = model.journey.landmarks.count - 1
        return "\(model.arrivals.count) / \(total) 枚"
    }

    var nextNote: String {
        guard let landmark = model.nextLandmark, let remaining = model.kilometersToNext else {
            return "京都に着きました"
        }

        return "あと \(remaining.formatted()) km で\(landmark.name)"
    }

    var progressRatio: Double {
        let total = max(1, model.journey.totalKilometers)
        return Double(model.kilometers) / Double(total)
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
