import Core
import DesignSystem
import FeatureModels
import SwiftUI

public struct TripResultSheet: View {
    @State private var picker: JourneyPickerModel?

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
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("閉じる", systemImage: "xmark") {
                            onClose()
                        }
                    }
                }
                .navigationDestination(for: Landmark.self) { landmark in
                    if let arrival = model.finishedArrivals
                        .first(where: { $0.landmark == landmark }) {
                        LandmarkArrivalView(arrival: arrival) { isDecorated in
                            model.setDecorated(isDecorated, landmark: landmark)
                        }
                    }
                }
        }
        .sheet(item: $picker) { picker in
            JourneyPickerSheet(model: picker) {
                self.picker = nil
                onClose()
                model.refresh()
            }
            .presentationDetents([.large])
        }
    }
}

private extension TripResultSheet {
    var content: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                header

                VStack(spacing: Spacing.small) {
                    Text("おかえり！")
                        .handwritingFont(size: 34)
                        .foregroundStyle(Palette.ink)

                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)

                    Text(gainText)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.teal)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                if !model.finishedArrivals.isEmpty {
                    receivedCard
                }

                if !trip.isPractice, model.nextLandmark == nil {
                    finishedCard
                } else if !trip.isPractice {
                    routeCard
                }

                Button("部屋に戻る") {
                    onClose()
                }
                .buttonStyle(.pill)
            }
            .padding(Spacing.medium)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(PaperBackdrop())
    }

    var header: some View {
        VStack(spacing: Spacing.small) {
            TapedPhoto(caption: badge, tilt: -1.5) {
                Color.clear
                    .aspectRatio(LandmarkArt.aspectRatio, contentMode: .fit)
                    .overlay {
                        headerArt
                    }
                    .clipped()
            }
            .overlay(alignment: .bottomLeading) {
                if let companion = model.companion {
                    CompanionSticker(companion: companion, pose: pose, size: 80)
                        .offset(x: -Spacing.small, y: -Spacing.large - Spacing.medium)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if !model.finishedArrivals.isEmpty {
                    Postmark(date: trip.endedAt ?? trip.plannedEnd)
                        .offset(x: Spacing.small, y: Spacing.large)
                }
            }
            .padding(.bottom, Spacing.small)
        }
        .padding(.top, Spacing.small)
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
            CardLabel(
                "届いたもの",
                systemImage: "envelope.fill",
                tint: Palette.coralDeep,
                wash: Palette.coralSoft
            )

            ForEach(model.finishedArrivals, id: \.landmark.name) { arrival in
                NavigationLink(value: arrival.landmark) {
                    receivedRow(arrival)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
    }

    var routeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            CardLabel(
                "道のり",
                systemImage: "map.fill",
                tint: Palette.tealDeep,
                wash: Palette.tealSoft
            )

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
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
    }

    var finishedCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack(alignment: .center, spacing: Spacing.medium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.journey.name)
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text("を歩ききった！")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Palette.muted)
                }

                Spacer()

                FinishStamp()
            }

            Button("次の道のりを選ぶ") {
                picker = model.makeJourneyPicker()
            }
            .buttonStyle(.pill)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
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
    var gainText: String {
        trip.isPractice ? "おるす駅" : "+\(trip.kilometers(at: .now)) km"
    }

    var summary: String {
        if trip.isPractice {
            return trip.isCompleted ? "10 秒の練習の旅、おつかれさま" : "練習の旅は、またいつでも"
        }

        guard trip.endedAt != nil else {
            let hours = trip.plannedMinutes / 60
            let minutes = trip.plannedMinutes % 60
            let length = switch (hours, minutes) {
            case (0, _): "\(minutes) 分"
            case (_, 0): "\(hours) 時間"
            default: "\(hours) 時間 \(minutes) 分"
            }

            return "\(length)、スマホを置いて旅してきたよ"
        }

        return "\(trip.focusedMinutes(at: .now)) 分で切り上げました"
    }

    var pose: Companion.Pose {
        trip.endedAt == nil ? .joy : .wave
    }

    var destination: String {
        model.journey.landmarks.last?.name ?? "目的地"
    }

    var badge: String {
        if let arrival = model.finishedArrivals.last {
            return "\(arrival.landmark.name)に着いた！"
        }

        guard let landmark = model.nextLandmark else {
            return "\(destination)に着いた"
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
            return "\(destination)に着きました"
        }

        return "次は\(landmark.name) あと \(remaining.formatted()) km"
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

        return "\(arrival.landmark.kilometer.formatted()) km · \(time)"
    }
}
