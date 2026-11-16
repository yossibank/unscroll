import DesignSystem
import SwiftUI

struct RoomTripCard: View {
    let model: RoomModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            CardLabel(
                "旅の長さ",
                systemImage: "timer",
                tint: Palette.coral,
                wash: Palette.coralSoft
            )

            lengthStepper

            lengthSlider

            LazyVGrid(columns: presetColumns, spacing: Spacing.small) {
                ForEach(RoomModel.tripPresets, id: \.self) { minutes in
                    presetButton(minutes)
                }
            }

            Button {
                model.startTrip()
            } label: {
                Label(model.startTitle, systemImage: "backpack.fill")
            }
            .buttonStyle(.pill)
            .disabled(!model.canStart)

            if !model.isAuthorized || !model.hasSelection {
                Label("設定で、許可と止めるアプリを選んでください", systemImage: "info.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }
        }
        .roundedCard()
    }
}

private extension RoomTripCard {
    var lengthStepper: some View {
        HStack(spacing: Spacing.medium) {
            stepButton(systemImage: "minus", isEnabled: model.canShorten) {
                model.shorten()
            }

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(model.selectedMinutes)")
                        .font(.largeTitle.weight(.heavy))
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(model.selectedMinutes)))

                    Text("分")
                        .font(.headline.weight(.heavy))
                }
                .foregroundStyle(Palette.ink)

                Text(model.lengthNote(for: model.selectedMinutes))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.tealDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .animation(.snappy, value: model.selectedMinutes)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("旅の長さ")
            .accessibilityValue(
                "\(model.selectedMinutes) 分、\(model.lengthNote(for: model.selectedMinutes))"
            )
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    model.lengthen()

                case .decrement:
                    model.shorten()

                @unknown default:
                    break
                }
            }

            stepButton(systemImage: "plus", isEnabled: model.canLengthen) {
                model.lengthen()
            }
        }
        .padding(.vertical, Spacing.small)
        .padding(.horizontal, Spacing.small)
        .background(Palette.paper, in: .rect(cornerRadius: 20))
    }

    var lengthSlider: some View {
        VStack(spacing: 4) {
            Slider(
                value: sliderMinutes,
                in: Double(RoomModel.tripStep)...Double(RoomModel.tripRange.upperBound),
                step: Double(RoomModel.tripStep)
            ) {
                Text("旅の長さ")
            }
            .tint(Palette.teal)
            .sensoryFeedback(.selection, trigger: model.selectedMinutes)

            HStack {
                Text("5 分")

                Spacer()

                Text("1 時間")

                Spacer()

                Text("2 時間")

                Spacer()

                Text("3 時間")
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(Palette.muted)
            .accessibilityHidden(true)
        }
    }

    func stepButton(
        systemImage: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.heavy))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Palette.teal, in: Circle())
                .shadow(color: Palette.teal.opacity(0.35), radius: 6, y: 4)
        }
        .buttonStyle(.plain)
        .buttonRepeatBehavior(.enabled)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .accessibilityHidden(true)
    }

    func presetButton(_ minutes: Int) -> some View {
        let isSelected = model.selectedMinutes == minutes

        return Button {
            model.selectedMinutes = minutes
        } label: {
            Text(presetTitle(minutes))
                .font(.subheadline.weight(.heavy))
                .monospacedDigit()
                .foregroundStyle(isSelected ? Color.white : Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, Spacing.small)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Palette.teal : Palette.paper, in: Capsule())
                .animation(.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(minutes) 分にする")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension RoomTripCard {
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

    func presetTitle(_ minutes: Int) -> String {
        switch (minutes / 60, minutes % 60) {
        case (0, _): "\(minutes) 分"
        case let (hours, 0): "\(hours) 時間"
        case let (hours, 30): "\(hours) 時間半"
        case let (hours, rest): "\(hours) 時間 \(rest) 分"
        }
    }
}
