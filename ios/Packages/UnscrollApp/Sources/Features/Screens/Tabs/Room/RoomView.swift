import Core
import DesignSystem
import SwiftUI

public struct RoomView: View {
    @State private var model: RoomModel
    @State private var isTripCoverShown = false

    @Environment(\.scenePhase) private var scenePhase

    public init(model: RoomModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    distanceCard

                    wallCard

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
            .onChange(of: scenePhase) {
                model.refresh()
            }
            .refreshable {
                model.refresh()
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

    var wallCard: some View {
        card {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("飾った絵はがき")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                if model.decoratedArrivals.isEmpty {
                    Text("名所に着くと届く絵はがきを、ここに飾れます")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                } else {
                    ScrollView(.horizontal) {
                        HStack(spacing: Spacing.small) {
                            ForEach(model.decoratedArrivals, id: \.landmark.name) { arrival in
                                wallPostcard(arrival)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
    }

    func wallPostcard(_ arrival: Arrival) -> some View {
        VStack(spacing: 4) {
            PostcardArt(
                landmark: arrival.landmark,
                symbolFont: .title2,
                showsProvisionalMark: false
            )
            .frame(width: 96)

            Text(arrival.landmark.name)
                .font(.caption2.bold())
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(6)
        .background(Palette.paper, in: RoundedRectangle(cornerRadius: 8))
        .rotationEffect(.degrees(arrival.landmark.kilometer.isMultiple(of: 20) ? -2 : 2))
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
                    Text("\(model.selectedMinutes) 分 旅に出す")
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

    func card(
        @ViewBuilder content: () -> some View
    ) -> some View {
        content()
            .padding(Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
