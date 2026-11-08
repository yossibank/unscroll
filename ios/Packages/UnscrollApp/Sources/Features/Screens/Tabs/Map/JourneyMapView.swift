import Core
import DesignSystem
import SwiftUI

public struct JourneyMapView: View {
    @State private var model: JourneyMapModel

    @Environment(\.scenePhase) private var scenePhase

    public init(model: JourneyMapModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    header

                    mapFrame

                    distance

                    nextCard

                    stamps
                }
                .padding(Spacing.medium)
            }
            .background(Palette.paper)
            .navigationTitle("地図")
            .onAppear {
                model.refresh()
            }
            .onChange(of: scenePhase) {
                model.refresh()
            }
            .refreshable {
                model.refresh()
            }
        }
    }
}

private extension JourneyMapView {
    var header: some View {
        HStack {
            Text(model.journey.name)
                .font(.title3.bold())
                .foregroundStyle(Palette.ink)

            Spacer()

            Text("1 本目の道のり")
                .font(.caption.bold())
                .foregroundStyle(Palette.teal)
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, 4)
                .background(Palette.teal.opacity(0.12), in: Capsule())
        }
    }

    var mapFrame: some View {
        JourneyMapCanvas(journey: model.journey, kilometers: model.kilometers)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(Spacing.small)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    var distance: some View {
        VStack(spacing: Spacing.small) {
            HStack {
                Text("\(model.kilometers) / \(model.journey.totalKilometers) km")
                    .font(.headline)
                    .foregroundStyle(Palette.ink)

                Spacer()

                Text("あと \(model.remainingKilometers) km")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            ProgressView(value: model.progressRatio)
                .tint(Palette.teal)
        }
    }

    var nextCard: some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "mappin.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(Palette.teal)

            VStack(alignment: .leading, spacing: 4) {
                if let landmark = model.nextLandmark, let remaining = model.kilometersToNext {
                    Text("次の名所")
                        .font(.caption)
                        .foregroundStyle(Palette.muted)

                    Text(landmark.name)
                        .font(.headline)
                        .foregroundStyle(Palette.ink)

                    Text(note(remaining: remaining))
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                } else {
                    Text("京都に着きました")
                        .font(.headline)
                        .foregroundStyle(Palette.ink)
                }
            }

            Spacer()
        }
        .padding(Spacing.medium)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    var stamps: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: Spacing.small) {
                ForEach(model.journey.landmarks.dropFirst(), id: \.name) { landmark in
                    stamp(landmark)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    func stamp(_ landmark: Landmark) -> some View {
        let isReached = model.isReached(landmark)
        let dash = StrokeStyle(lineWidth: 2, dash: [4, 3])

        return VStack(spacing: 4) {
            if isReached {
                Text("U")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Palette.coral.opacity(0.2), in: Circle())
                    .overlay {
                        Circle().stroke(Palette.coral, lineWidth: 2)
                    }
                    .rotationEffect(.degrees(-8))
            } else {
                Text("?")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.muted)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Circle().stroke(Palette.muted.opacity(0.5), style: dash)
                    }
            }

            Text(landmark.name)
                .font(.caption2.bold())
                .foregroundStyle(isReached ? Palette.ink : Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 60)
    }

    func note(remaining: Int) -> String {
        let minutes = remaining / Trip.kilometersPerMinute
        return "あと \(remaining) km · 約 \(minutes) 分の集中で届く"
    }
}
