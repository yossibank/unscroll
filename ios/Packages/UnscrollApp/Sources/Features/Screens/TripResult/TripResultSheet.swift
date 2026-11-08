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
        ScrollView {
            VStack(spacing: Spacing.medium) {
                Text("おかえり！")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Palette.ink)

                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                ForEach(model.finishedArrivals, id: \.landmark.name) { arrival in
                    arrivalCard(arrival)
                }

                Text("+\(trip.kilometers(at: .now)) km")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.teal)

                totalCard

                souvenirCard

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
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Palette.paper)
    }
}

private extension TripResultSheet {
    var summary: String {
        guard trip.endedAt != nil else {
            return "\(trip.plannedMinutes) 分の旅が終わりました"
        }

        return "\(trip.focusedMinutes(at: .now)) 分で切り上げました"
    }

    var totalCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("合わせて \(model.kilometers) km")
                .font(.headline)
                .foregroundStyle(Palette.ink)

            if let landmark = model.nextLandmark, let remaining = model.kilometersToNext {
                Text("次は\(landmark.name) あと \(remaining) km")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            } else {
                Text("京都に着きました")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    var souvenirCard: some View {
        ZStack(alignment: .topTrailing) {
            Text("名所に着いた時の絵はがきとおみやげは、あとで届くようにします。")
                .font(.footnote)
                .foregroundStyle(Palette.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, Spacing.large)

            ProvisionalMark()
        }
        .padding(Spacing.medium)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    func arrivalCard(_ arrival: Arrival) -> some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(Palette.teal)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(arrival.landmark.name)に着いたよ！")
                    .font(.headline)
                    .foregroundStyle(Palette.ink)

                Text(arrivalDetail(arrival))
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
            }

            Spacer()
        }
        .padding(Spacing.medium)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
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
