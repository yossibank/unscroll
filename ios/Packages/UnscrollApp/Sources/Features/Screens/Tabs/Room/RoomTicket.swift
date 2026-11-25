import Core
import DesignSystem
import FeatureModels
import SwiftUI

struct RoomTicket: View {
    let model: RoomModel

    var body: some View {
        HStack(spacing: 0) {
            main

            stub
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Palette.card)
        .clipShape(TicketShape(stubWidth: Self.stubWidth))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
    }
}

private extension RoomTicket {
    static let stubWidth: CGFloat = 104

    var main: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("旅のきっぷ")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Palette.teal)
                    .tracking(2)

                Spacer(minLength: Spacing.small)

                Text(distanceNote)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            HStack(spacing: Spacing.small) {
                Text("部屋")

                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.black))
                    .foregroundStyle(Palette.coral)

                Text(destination)
            }
            .journalTitleFont(size: 19)
            .foregroundStyle(Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            TicketGauge(ratio: progressRatio)
                .padding(.top, 4)

            Text(nextNote)
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            LazyVGrid(columns: presetColumns, spacing: Spacing.small) {
                ForEach(RoomModel.tripPresets, id: \.self) { minutes in
                    presetButton(minutes)
                }
            }
            .padding(.top, Spacing.small)

            Slider(
                value: sliderMinutes,
                in: Double(RoomModel.tripStep)...Double(RoomModel.tripRange.upperBound),
                step: Double(RoomModel.tripStep)
            ) {
                Text("旅の長さ")
            }
            .tint(Palette.teal)
            .sensoryFeedback(.selection, trigger: model.selectedMinutes)
            .accessibilityValue(lengthTitle(model.selectedMinutes))

            if !model.isAuthorized || !model.hasSelection {
                Label("設定で、許可と止めるアプリを選んでください", systemImage: "info.circle.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var stub: some View {
        Button {
            model.startTrip()
        } label: {
            VStack(spacing: 4) {
                Text(lengthTitle(model.selectedMinutes))
                    .font(.caption.weight(.heavy))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(model.selectedMinutes)))

                Text(model.lengthNote(for: model.selectedMinutes))
                    .font(.caption2.weight(.heavy))
                    .opacity(0.85)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text("旅に出る")
                    .journalTitleFont(size: 18)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.top, 4)

                Image(systemName: "backpack.fill")
                    .font(.headline)
            }
            .foregroundStyle(stubForeground)
            .padding(.horizontal, Spacing.small)
            .frame(width: Self.stubWidth)
            .frame(maxHeight: .infinity)
            .background(stubBackground)
            .overlay(alignment: .leading) {
                Rectangle()
                    .stroke(stubEdge, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .frame(width: 0.5)
                    .padding(.vertical, Spacing.small)
            }
            .animation(.snappy, value: model.selectedMinutes)
        }
        .buttonStyle(StubButtonStyle())
        .disabled(!model.canStart)
        .accessibilityLabel(model.startTitle)
        .accessibilityValue(model.lengthNote(for: model.selectedMinutes))
    }

    func presetButton(_ minutes: Int) -> some View {
        let isSelected = model.selectedMinutes == minutes
        let foreground = isSelected ? Color.white : Palette.muted
        let background = isSelected ? Palette.ink : Palette.paperDeep
        let traits: AccessibilityTraits = isSelected ? .isSelected : []

        return Button {
            model.selectedMinutes = minutes
        } label: {
            Text(lengthTitle(minutes))
                .font(.caption.weight(.heavy))
                .monospacedDigit()
                .foregroundStyle(foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, Spacing.small)
                .frame(maxWidth: .infinity)
                .background(background, in: .rect(cornerRadius: 8))
                .animation(.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) 分にする")
        .accessibilityAddTraits(traits)
    }
}

private extension RoomTicket {
    var destination: String {
        let landmark = model.nextLandmark ?? model.journey.landmarks.last
        return landmark?.name ?? ""
    }

    var distanceNote: String {
        let total = model.journey.totalKilometers
        return "\(model.kilometers.formatted()) / \(total.formatted()) km"
    }

    var nextNote: String {
        guard let remaining = model.kilometersToNext else {
            return "\(destination)に着きました"
        }

        return "あと \(remaining.formatted()) km・次の絵はがきまで"
    }

    var stubForeground: Color {
        model.canStart ? .white : Palette.muted
    }

    var stubBackground: Color {
        model.canStart ? Palette.teal : Palette.paperDeep
    }

    var stubEdge: Color {
        model.canStart ? .white.opacity(0.7) : Palette.floorEdge
    }

    var progressRatio: Double {
        let total = max(1, model.journey.totalKilometers)
        return Double(model.kilometers) / Double(total)
    }

    var presetColumns: [GridItem] {
        let column = GridItem(.flexible(), spacing: Spacing.small)
        return Array(repeating: column, count: 3)
    }

    var sliderMinutes: Binding<Double> {
        Binding(
            get: {
                Double(model.selectedMinutes)
            },
            set: { value in
                model.selectedMinutes = Int(value.rounded())
            }
        )
    }

    func lengthTitle(_ minutes: Int) -> String {
        switch (minutes / 60, minutes % 60) {
        case (0, _): "\(minutes) 分"
        case let (hours, 0): "\(hours) 時間"
        case let (hours, 30): "\(hours) 時間半"
        case let (hours, rest): "\(hours) 時間 \(rest) 分"
        }
    }
}

private struct StubButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}
