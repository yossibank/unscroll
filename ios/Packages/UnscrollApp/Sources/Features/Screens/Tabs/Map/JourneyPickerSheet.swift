import Core
import DesignSystem
import SwiftUI

struct JourneyPickerSheet: View {
    @State private var model: JourneyPickerModel

    let onSelected: () -> Void

    init(
        model: JourneyPickerModel,
        onSelected: @escaping () -> Void
    ) {
        _model = State(initialValue: model)
        self.onSelected = onSelected
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("どこへ行く？")
                .font(.title3.weight(.heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.large)
                .padding(.bottom, Spacing.small)

            ScrollView {
                VStack(spacing: Spacing.small + 4) {
                    ForEach(model.journeys, id: \.id) { journey in
                        card(journey)
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small)
            }
            .scrollBounceBehavior(.basedOnSize)

            footer
        }
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .background(Palette.paper)
    }
}

private extension JourneyPickerSheet {
    var footer: some View {
        let journey = model.selectedJourney

        return VStack(alignment: .leading, spacing: Spacing.small + 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(journey.name)
                    .font(.headline.weight(.heavy))

                Spacer()

                Text(summary(journey))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .monospacedDigit()
            }

            landmarkRow(journey)

            Button("この道のりにする") {
                if model.confirm() {
                    onSelected()
                }
            }
            .buttonStyle(.pill)
            .disabled(!model.canConfirm)
        }
        .padding(Spacing.medium)
        .background(
            Palette.card,
            in: .rect(topLeadingRadius: 24, topTrailingRadius: 24)
        )
        .shadow(color: Palette.shadow, radius: 12, y: -4)
    }

    func card(_ journey: Journey) -> some View {
        let isSelected = model.selectedID == journey.id

        return Button {
            model.selectedID = journey.id
        } label: {
            VStack(spacing: 0) {
                band(journey)

                HStack(alignment: .firstTextBaseline, spacing: Spacing.small) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(journey.name)
                            .font(.headline.weight(.heavy))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(detail(journey))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Palette.muted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }

                    Spacer()

                    Text("\(journey.totalKilometers) km")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(Palette.tealDeep)
                        .monospacedDigit()
                }
                .padding(Spacing.small + 4)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Palette.card, in: .rect(cornerRadius: 20))
            .clipShape(.rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? Palette.teal : .clear, lineWidth: 3)
            }
            .shadow(color: Palette.shadow, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func band(_ journey: Journey) -> some View {
        let landmarks = journey.landmarks
        let middle = landmarks.dropFirst(landmarks.count / 2).first
        let picks = [landmarks.first, middle, landmarks.last].compactMap(\.self)
        let isSelected = model.selectedID == journey.id

        return HStack(spacing: 2) {
            ForEach(picks.indices, id: \.self) { index in
                LandmarkArt(landmark: picks[index])
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 76)
                    .clipped()
            }
        }
        .frame(height: 76)
        .clipped()
        .overlay(alignment: .bottomLeading) {
            if model.isCurrent(journey) {
                Text(currentText(journey))
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Palette.tealDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, Spacing.small)
                    .frame(minHeight: 24)
                    .background(Palette.card, in: Capsule())
                    .padding(Spacing.small)
            }
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.teal)
                    .frame(width: 24, height: 24)
                    .background(Palette.card, in: Circle())
                    .padding(Spacing.small)
            }
        }
    }

    func landmarkRow(_ journey: Journey) -> some View {
        let landmarks = journey.landmarks

        return ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(landmarks.indices, id: \.self) { index in
                    VStack(spacing: 4) {
                        HStack(spacing: 0) {
                            line(isVisible: index > 0)

                            Circle()
                                .fill(Palette.teal)
                                .frame(width: 12, height: 12)

                            line(isVisible: index < landmarks.count - 1)
                        }

                        Text(landmarks[index].name)
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(Palette.muted)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: 60)
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
    }

    func line(isVisible: Bool) -> some View {
        Rectangle()
            .fill(isVisible ? Palette.teal.opacity(0.4) : .clear)
            .frame(height: 3)
    }
}

private extension JourneyPickerSheet {
    func summary(_ journey: Journey) -> String {
        let focus = JourneyPickerModel.focusText(kilometers: journey.totalKilometers)
        return "\(journey.totalKilometers.formatted()) km・\(focus)の集中"
    }

    func detail(_ journey: Journey) -> String {
        let focus = JourneyPickerModel.focusText(kilometers: journey.totalKilometers)
        return "名所 \(journey.landmarks.count)・\(focus)"
    }

    func currentText(_ journey: Journey) -> String {
        let done = model.kilometers(of: journey)
        return "今の道のり・\(done.formatted()) km 進みました"
    }
}
