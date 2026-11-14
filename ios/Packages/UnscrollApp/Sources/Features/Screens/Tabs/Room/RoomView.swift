import Core
import DesignSystem
import SwiftUI

public struct RoomView: View {
    @State private var model: RoomModel
    @State private var isTripCoverShown = false
    @State private var pose = Companion.Pose.walk
    @State private var pokes = 0

    @Environment(\.scenePhase) private var scenePhase

    public init(model: RoomModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    companionCard

                    distanceCard

                    tripCard

                    usageCard
                }
                .padding(Spacing.medium)
            }
            .background(Palette.paper)
            .navigationTitle("Unscroll")
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
        }
    }
}

private extension RoomView {
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

private extension RoomView {
    var distanceCard: some View {
        card {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("進んだ距離")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                Text("\(model.kilometers) km")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)

                Text(model.journey.name)
                    .foregroundStyle(Palette.ink)

                nextLandmarkLine
            }
        }
    }

    var nextLandmarkLine: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(Palette.teal)

            if let landmark = model.nextLandmark, let remaining = model.kilometersToNext {
                Text("次は\(landmark.name)")
                    .foregroundStyle(Palette.ink)

                Text("あと \(remaining) km")
                    .foregroundStyle(Palette.muted)
            } else {
                Text("京都に着きました")
                    .foregroundStyle(Palette.ink)
            }
        }
        .font(.subheadline)
    }

    var companionCard: some View {
        VStack(spacing: 0) {
            scene

            if let companion = model.companion {
                HStack {
                    Text(companion.name)
                        .font(.headline)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text("触ると喜ぶ")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small + 4)
            }
        }
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    var scene: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                wall

                Spacer()

                Palette.floor
                    .frame(height: 64)
                    .overlay(alignment: .top) {
                        Palette.floorEdge
                            .frame(height: 4)
                    }
            }

            if let companion = model.companion {
                Button {
                    poke()
                } label: {
                    CompanionSticker(companion: companion, pose: pose, size: 128)
                }
                .buttonStyle(.plain)
                .padding(.bottom, Spacing.medium)
            }
        }
        .frame(height: 280)
        .background(Palette.wall)
    }

    var wall: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: Spacing.small + 4) {
                ForEach(model.decoratedArrivals, id: \.landmark.name) { arrival in
                    wallPostcard(arrival)
                }

                if let remaining = model.kilometersToNext {
                    nextPostcardSlot(remaining)
                }
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small + 4)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
    }

    var tripCard: some View {
        card {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("旅の長さ")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                HStack(spacing: Spacing.small) {
                    ForEach(RoomModel.tripLengths, id: \.self) { minutes in
                        lengthButton(minutes)
                    }
                }

                Button {
                    model.startTrip()
                } label: {
                    Text(model.startTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.teal)
                .disabled(!model.canStart)

                if !model.isAuthorized || !model.hasSelection {
                    Text("設定で、許可と止めるアプリを選んでください")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                }
            }
        }
    }

    var usageCard: some View {
        card {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("今日のスマホ")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                UsageReportView()
                    .frame(height: 240)
            }
        }
    }

    func nextPostcardSlot(_ remaining: Int) -> some View {
        VStack(spacing: 2) {
            Text("次の絵はがき")
            Text("あと \(remaining) km")
        }
        .font(.caption2)
        .foregroundStyle(Palette.muted)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(width: 84, height: 72)
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Palette.floorEdge, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        }
    }

    func wallPostcard(_ arrival: Arrival) -> some View {
        VStack(spacing: 4) {
            PostcardArt(
                landmark: arrival.landmark,
                symbolFont: .title3,
                showsProvisionalMark: false
            )
            .frame(width: 72)

            Text(arrival.landmark.name)
                .font(.caption2.bold())
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(6)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 4))
        .shadow(color: Palette.ink.opacity(0.18), radius: 2, x: 0, y: 2)
        .rotationEffect(.degrees(arrival.landmark.kilometer.isMultiple(of: 20) ? -2 : 2))
    }

    func lengthButton(_ minutes: Int) -> some View {
        let isSelected = model.selectedMinutes == minutes
        let shape = RoundedRectangle(cornerRadius: 12)

        return Button {
            model.selectedMinutes = minutes
        } label: {
            VStack(spacing: 4) {
                Text("\(minutes) 分")
                    .font(.headline)
                    .foregroundStyle(Palette.ink)

                Text(model.lengthNote(for: minutes))
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, Spacing.small)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Palette.teal.opacity(0.12) : Palette.card, in: shape)
            .overlay {
                shape.stroke(
                    isSelected ? Palette.teal : Palette.muted.opacity(0.3),
                    lineWidth: isSelected ? 2 : 1
                )
            }
        }
        .buttonStyle(.plain)
    }

    func card(@ViewBuilder content: () -> some View) -> some View {
        content()
            .padding(Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
