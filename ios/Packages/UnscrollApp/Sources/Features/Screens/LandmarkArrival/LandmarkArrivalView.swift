import Core
import DesignSystem
import SwiftUI

public struct LandmarkArrivalView: View {
    private let arrival: Arrival
    private let onDecorate: (Bool) -> Void

    @State private var isDecorated: Bool

    public init(
        arrival: Arrival,
        onDecorate: @escaping (Bool) -> Void
    ) {
        self.arrival = arrival
        self.onDecorate = onDecorate
        _isDecorated = State(initialValue: arrival.isDecorated)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                Text("\(arrival.landmark.name)に着いたよ！")
                    .font(.title2.bold())
                    .foregroundStyle(Palette.ink)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                postcard

                if let souvenir = arrival.landmark.souvenir {
                    souvenirCard(souvenir)
                }

                decorateButton
            }
            .padding(Spacing.medium)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Palette.paper)
        .navigationTitle(arrival.landmark.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension LandmarkArrivalView {
    var detail: String {
        let format = Date.VerbatimFormatStyle(
            format: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: .current,
            calendar: .current
        )

        return "\(arrival.landmark.kilometer) km · \(arrival.arrivedAt.formatted(format))"
    }

    var postcard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            PostcardArt(landmark: arrival.landmark, symbolFont: .system(size: 64))

            Text("絵はがき")
                .font(.caption.bold())
                .foregroundStyle(Palette.muted)
        }
        .padding(Spacing.small)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 12))
        .rotationEffect(.degrees(-1.5))
        .padding(.horizontal, Spacing.small)
    }

    func souvenirCard(_ souvenir: String) -> some View {
        HStack(spacing: Spacing.small) {
            Image(systemName: "gift.fill")
                .font(.title2)
                .foregroundStyle(Palette.coral)

            VStack(alignment: .leading, spacing: 4) {
                Text("おみやげ")
                    .font(.caption)
                    .foregroundStyle(Palette.muted)

                Text(souvenir)
                    .font(.headline)
                    .foregroundStyle(Palette.ink)
            }

            Spacer()

            ProvisionalMark()
        }
        .padding(Spacing.medium)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    var decorateButton: some View {
        if isDecorated {
            VStack(spacing: Spacing.small) {
                Label("部屋に飾っています", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(Palette.teal)

                Button("部屋から外す") {
                    setDecorated(false)
                }
                .buttonStyle(.bordered)
                .tint(Palette.muted)
            }
        } else {
            Button {
                setDecorated(true)
            } label: {
                Label("部屋に飾る", systemImage: "pin")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Palette.teal)
        }
    }

    func setDecorated(_ value: Bool) {
        isDecorated = value
        onDecorate(value)
    }
}
