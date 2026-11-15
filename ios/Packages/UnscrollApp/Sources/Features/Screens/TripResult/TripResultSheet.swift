import Core
import DesignSystem
import SwiftUI

public struct TripResultSheet: View {
    private let trip: Trip
    private let model: RoomModel
    private let onClose: () -> Void

    public init(
        trip: Trip,
        model: RoomModel,
        onClose: @escaping () -> Void
    ) {
        self.trip = trip
        self.model = model
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationDestination(for: Landmark.self) { landmark in
                    if let arrival = model.finishedArrivals
                        .first(where: { $0.landmark == landmark }) {
                        LandmarkArrivalView(arrival: arrival) { isDecorated in
                            model.setDecorated(isDecorated, landmark: landmark)
                        }
                    }
                }
        }
    }
}

private extension TripResultSheet {
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(spacing: Spacing.medium) {
                    VStack(spacing: Spacing.small) {
                        Text("おかえり！")
                            .font(.title.weight(.bold))
                            .foregroundStyle(Palette.ink)

                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(Palette.muted)

                        Text("+\(trip.kilometers(at: .now)) km")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Palette.teal)
                    }

                    if !model.finishedArrivals.isEmpty {
                        receivedCard
                    }

                    routeCard

                    Button {
                        onClose()
                    } label: {
                        Text("部屋に戻る")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Palette.teal)
                }
                .padding(Spacing.medium)
                .padding(.top, Spacing.small)
                .background(
                    Palette.paper,
                    in: UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                )
                .offset(y: -Spacing.large)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Palette.paper)
    }

    var header: some View {
        Color.clear
            .aspectRatio(LandmarkArt.aspectRatio, contentMode: .fit)
            .overlay {
                headerArt
            }
            .overlay(alignment: .topLeading) {
                Text(badge)
                    .font(.caption.bold())
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 4)
                    .background(Palette.card, in: Capsule())
                    .padding(Spacing.medium)
            }
            .overlay(alignment: .bottom) {
                if let companion = model.companion {
                    CompanionSticker(companion: companion, pose: pose, size: 96)
                        .padding(.bottom, Spacing.large)
                }
            }
            .clipped()
    }

    @ViewBuilder
    var headerArt: some View {
        if let arrival = model.finishedArrivals.last {
            LandmarkArt(landmark: arrival.landmark)
        } else if let landmark = model.nextLandmark ?? model.journey.landmarks.last {
            TripScenery(
                landmark: landmark,
                period: DayPeriod(date: .now),
                isMoving: false
            )
        }
    }

    var receivedCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("届いたもの")
                .font(.footnote.bold())
                .foregroundStyle(Palette.muted)

            ForEach(model.finishedArrivals, id: \.landmark.name) { arrival in
                NavigationLink(value: arrival.landmark) {
                    receivedRow(arrival)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    var routeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("道のり")
                .font(.footnote.bold())
                .foregroundStyle(Palette.muted)

            JourneyRoute(
                journey: model.journey,
                companion: model.companion,
                start: tripStart,
                end: walked
            )

            HStack(alignment: .firstTextBaseline) {
                Text("合わせて \(model.kilometers) km")
                    .font(.headline)
                    .foregroundStyle(Palette.ink)

                Spacer()

                Text(nextNote)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            HStack(spacing: Spacing.medium) {
                legend("この旅", color: Palette.coral)
                legend("これまで", color: Palette.teal)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    func receivedRow(_ arrival: Arrival) -> some View {
        HStack(spacing: Spacing.medium) {
            PostcardArt(landmark: arrival.landmark)
                .padding(3)
                .background(Palette.card, in: RoundedRectangle(cornerRadius: 4))
                .shadow(color: Palette.ink.opacity(0.25), radius: 3, y: 2)
                .rotationEffect(.degrees(-3))
                .frame(width: 128)
                .overlay(alignment: .bottomTrailing) {
                    SouvenirArt(landmark: arrival.landmark, size: 48)
                        .offset(x: 12, y: 12)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(arrival.landmark.name)
                    .font(.headline)
                    .foregroundStyle(Palette.ink)

                Text(gift(arrival.landmark))
                    .font(.caption)
                    .foregroundStyle(Palette.muted)

                Text(arrivalDetail(arrival))
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
            }
            .padding(.leading, Spacing.small)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.bold())
                .foregroundStyle(Palette.muted)
        }
        .padding(.bottom, Spacing.small)
        .contentShape(Rectangle())
    }

    func legend(
        _ title: String,
        color: Color
    ) -> some View {
        HStack(spacing: 4) {
            Capsule()
                .fill(color)
                .frame(width: 12, height: 4)

            Text(title)
        }
        .font(.caption2)
        .foregroundStyle(Palette.muted)
    }
}

private extension TripResultSheet {
    var summary: String {
        guard trip.endedAt != nil else {
            return "\(trip.plannedMinutes) 分の旅が終わりました"
        }

        return "\(trip.focusedMinutes(at: .now)) 分で切り上げました"
    }

    var pose: Companion.Pose {
        trip.endedAt == nil ? .joy : .wave
    }

    var badge: String {
        if let arrival = model.finishedArrivals.last {
            return "\(arrival.landmark.name)に着いた"
        }

        guard let landmark = model.nextLandmark else {
            return "京都に着いた"
        }

        return "\(landmark.name)へ向かう途中"
    }

    var walked: Int {
        min(model.kilometers, model.journey.totalKilometers)
    }

    var tripStart: Int {
        max(walked - trip.kilometers(at: .now), 0)
    }

    var nextNote: String {
        guard
            let landmark = model.nextLandmark,
            let remaining = model.kilometersToNext
        else {
            return "京都に着きました"
        }

        return "次は\(landmark.name) あと \(remaining) km"
    }

    func gift(_ landmark: Landmark) -> String {
        guard let souvenir = landmark.souvenir else {
            return "絵はがき"
        }

        return "絵はがきと\(souvenir)"
    }

    func arrivalDetail(_ arrival: Arrival) -> String {
        let format = Date.VerbatimFormatStyle(
            format: "\(month: .defaultDigits)/\(day: .defaultDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: .current,
            calendar: .current
        )
        let time = arrival.arrivedAt.formatted(format)

        return "\(arrival.landmark.kilometer) km · \(time)"
    }
}
