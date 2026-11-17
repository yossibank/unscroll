import Core
import DesignSystem
import SwiftUI

public struct JourneyMapView: View {
    @State private var model: JourneyMapModel
    @State private var picker: JourneyPickerModel?

    @Environment(\.scenePhase) private var scenePhase

    private let onJourneyChanged: () -> Void

    public init(
        model: JourneyMapModel,
        onJourneyChanged: @escaping () -> Void = {}
    ) {
        _model = State(initialValue: model)
        self.onJourneyChanged = onJourneyChanged
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                header

                map
                    .clipShape(.rect(cornerRadius: 16))
                    .roundedCard(padding: Spacing.small)

                nextCard

                stamps
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
        .sheet(item: $picker) { picker in
            JourneyPickerSheet(model: picker) {
                self.picker = nil
                model.refresh()
                onJourneyChanged()
            }
            .presentationDetents([.fraction(0.65), .large])
        }
    }
}

private extension JourneyMapView {
    @ViewBuilder
    var map: some View {
        if let geometry = JourneyMapGeometry.for(model.journey.id) {
            JourneyMapCanvas(
                journey: model.journey,
                geometry: geometry,
                kilometers: model.kilometers,
                companion: model.companion
            )
        } else {
            Rectangle()
                .fill(Palette.paperDeep)
                .aspectRatio(MapBackdrop.aspectRatio, contentMode: .fit)
        }
    }

    var header: some View {
        HStack(spacing: Spacing.medium) {
            ProgressRing(
                ratio: model.progressRatio,
                label: "\(Int((model.progressRatio * 100).rounded()))%",
                tint: Palette.teal,
                wash: Palette.tealSoft
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(model.journey.name)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(Palette.ink)

                Text(distanceNote)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.teal)
                    .monospacedDigit()

                changeButton
            }
        }
        .roundedCard()
    }

    var changeButton: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                picker = model.makeJourneyPicker()
            } label: {
                Label("道のりを替える", systemImage: "arrow.triangle.swap")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(model.isOnTrip ? Palette.muted : Palette.tealDeep)
                    .padding(.horizontal, Spacing.small + 4)
                    .frame(minHeight: 28)
                    .background(
                        model.isOnTrip ? Palette.paperDeep : Palette.tealSoft,
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
            .disabled(model.isOnTrip)

            if model.isOnTrip {
                Text("旅から戻ると替えられる")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(.top, 4)
    }

    var nextCard: some View {
        HStack(spacing: Spacing.medium) {
            if model.nextLandmark == nil, let last = model.journey.landmarks.last {
                LandmarkArt(landmark: last)
                    .frame(width: 64)
                    .clipShape(.rect(cornerRadius: 8))
            } else {
                hiddenPostcard(width: 64)
            }

            VStack(alignment: .leading, spacing: 4) {
                if let landmark = model.nextLandmark, let remaining = model.kilometersToNext {
                    Text("次の名所")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Palette.sunDeep)

                    Text(landmark.name)
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Palette.ink)

                    Text(note(remaining: remaining))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.muted)
                } else {
                    Text("京都に着きました")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Palette.ink)
                }
            }
        }
        .roundedCard(fill: LinearGradient(
            colors: [Palette.sunSoft, Palette.card],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }

    var stamps: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            CardLabel(
                "届いた絵はがき",
                systemImage: "envelope.fill",
                tint: Palette.coral,
                wash: Palette.coralSoft
            ) {
                Text("\(reachedCount) / \(model.journey.landmarks.count - 1)")
                    .foregroundStyle(Palette.muted)
            }

            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: Spacing.small) {
                    ForEach(model.journey.landmarks.dropFirst(), id: \.name) { landmark in
                        stamp(landmark)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
        }
        .roundedCard()
    }

    func stamp(_ landmark: Landmark) -> some View {
        let isReached = model.isReached(landmark)

        return VStack(spacing: 4) {
            if isReached {
                LandmarkArt(landmark: landmark)
                    .frame(width: 64)
                    .clipShape(.rect(cornerRadius: 8))
            } else {
                hiddenPostcard(width: 64)
            }

            Text(landmark.name)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(isReached ? Palette.ink : Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(4)
        .background(Palette.card, in: .rect(cornerRadius: 12))
        .shadow(color: Palette.shadow, radius: 4, y: 3)
        .frame(width: 76)
    }

    func hiddenPostcard(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Palette.paperDeep)
            .overlay {
                Image(systemName: "questionmark")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Palette.muted.opacity(0.6))
            }
            .frame(width: width, height: width / LandmarkArt.aspectRatio)
    }
}

private extension JourneyMapView {
    var reachedCount: Int {
        model.journey.landmarks.dropFirst().filter { model.isReached($0) }.count
    }

    var distanceNote: String {
        let total = model.journey.totalKilometers
        return "\(model.kilometers.formatted()) / \(total.formatted()) km ・ あと \(model.remainingKilometers.formatted()) km"
    }

    func note(remaining: Int) -> String {
        let minutes = remaining / Trip.kilometersPerMinute
        return "あと \(remaining.formatted()) km ・ 約 \(minutes) 分の旅で届く"
    }
}
