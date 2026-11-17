import Core
import DesignSystem
import SwiftUI

public struct LandmarkArrivalView: View {
    @State private var isDecorated: Bool

    private let arrival: Arrival
    private let onDecorate: (Bool) -> Void

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
                VStack(spacing: 4) {
                    Text("\(arrival.landmark.name)に着いたよ！")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(Palette.ink)

                    TagPill(
                        detail,
                        systemImage: "mappin.and.ellipse",
                        tint: Palette.tealDeep,
                        wash: Palette.tealSoft
                    )
                }
                .padding(.top, Spacing.small)

                postcard

                if let art = SouvenirArt(landmark: arrival.landmark, size: 64),
                   let souvenir = arrival.landmark.souvenir {
                    souvenirCard(souvenir, art: art)
                }

                decorateButton
            }
            .padding(Spacing.medium)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(PaperBackdrop())
        .navigationTitle(arrival.landmark.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension LandmarkArrivalView {
    var postcard: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            PostcardArt(landmark: arrival.landmark)

            Text("絵はがき")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 4)
        }
        .padding(Spacing.small + 4)
        .background(Palette.card, in: .rect(cornerRadius: 20))
        .shadow(color: Palette.ink.opacity(0.12), radius: 12, y: 10)
        .rotationEffect(.degrees(-1.5))
        .padding(.horizontal, Spacing.small)
    }

    @ViewBuilder
    var decorateButton: some View {
        if isDecorated {
            VStack(spacing: Spacing.small) {
                TagPill(
                    "部屋に飾っています",
                    systemImage: "checkmark.circle.fill",
                    tint: Palette.tealDeep,
                    wash: Palette.tealSoft
                )

                Button("部屋から外す") {
                    setDecorated(false)
                }
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, Spacing.medium)
                .frame(minHeight: 40)
                .background(Palette.card, in: Capsule())
                .buttonStyle(.plain)
            }
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        } else {
            Button {
                setDecorated(true)
            } label: {
                Label("部屋に飾る", systemImage: "pin.fill")
            }
            .buttonStyle(.pill)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }

    func souvenirCard(
        _ souvenir: String,
        art: SouvenirArt
    ) -> some View {
        HStack(spacing: Spacing.medium) {
            art
                .padding(Spacing.small)
                .background(.white.opacity(0.7), in: .rect(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text("おみやげ")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.sunDeep)

                Text(souvenir)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Palette.ink)
            }
        }
        .roundedCard(fill: LinearGradient(
            colors: [Palette.sunSoft, Palette.card],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
}

private extension LandmarkArrivalView {
    var detail: String {
        let format = Date.VerbatimFormatStyle(
            format: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: .current,
            calendar: .current
        )

        return "\(arrival.landmark.kilometer.formatted()) km ・ \(arrival.arrivedAt.formatted(format))"
    }

    func setDecorated(_ value: Bool) {
        withAnimation(.spring(duration: 0.4, bounce: 0.35)) {
            isDecorated = value
        }

        onDecorate(value)
    }
}
