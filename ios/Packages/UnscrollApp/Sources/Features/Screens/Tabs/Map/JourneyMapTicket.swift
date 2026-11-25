import Core
import DesignSystem
import FeatureModels
import SwiftUI

struct JourneyMapTicket: View {
    let model: JourneyMapModel
    let onChange: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            main

            stub
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Palette.card, in: TicketShape(stubWidth: Self.stubWidth))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
    }
}

private extension JourneyMapTicket {
    static let stubWidth: CGFloat = 92

    var percent: Int {
        Int((model.progressRatio * 100).rounded())
    }

    var distanceNote: String {
        let total = model.journey.totalKilometers
        return "\(model.kilometers.formatted()) / \(total.formatted()) km"
    }

    var main: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("旅のきっぷ")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.teal)
                .tracking(2)

            HStack(spacing: Spacing.small) {
                Text(model.journey.landmarks.first?.name ?? "")

                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.black))
                    .foregroundStyle(Palette.coral)

                Text(model.journey.landmarks.last?.name ?? "")
            }
            .journalTitleFont(size: 19)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            TicketGauge(ratio: model.progressRatio)
                .padding(.top, 4)

            Text(distanceNote)
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.muted)
                .monospacedDigit()

            changeButton
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var stub: some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(percent)")
                    .journalTitleFont(size: 28)

                Text("%")
                    .font(.caption.weight(.heavy))
            }
            .foregroundStyle(Palette.teal)

            Text("すすんだ")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.muted)
        }
        .frame(width: Self.stubWidth)
        .frame(maxHeight: .infinity)
        .overlay(alignment: .leading) {
            Rectangle()
                .stroke(Palette.floorEdge, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .frame(width: 0.5)
                .padding(.vertical, Spacing.medium)
        }
        .accessibilityElement(children: .combine)
    }

    var changeButton: some View {
        VStack(alignment: .leading, spacing: 2) {
            Button(action: onChange) {
                Label("道のりを変える", systemImage: "arrow.triangle.swap")
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
                Text("旅から戻ると変えられます")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(.top, 4)
    }
}
