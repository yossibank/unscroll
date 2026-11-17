import Core
import DesignSystem
import SwiftUI

struct CompanionPickerForm: View {
    let model: CompanionPickerModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            speciesPicker

            coatPicker

            nameField
        }
    }
}

private extension CompanionPickerForm {
    var speciesPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            CardLabel(
                "キャラクター",
                systemImage: "pawprint.fill",
                tint: Palette.teal,
                wash: Palette.tealSoft
            )

            HStack(spacing: Spacing.small) {
                ForEach(Companion.Species.allCases, id: \.self) { species in
                    let sample = species.coats.first.flatMap { coat in
                        Companion(species: species, coat: coat, name: species.defaultName)
                    }

                    choiceButton(
                        title: species.label,
                        sample: sample,
                        isSelected: model.species == species,
                        action: {
                            model.select(species)
                        }
                    )
                }
            }
        }
        .roundedCard()
    }

    var coatPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            CardLabel(
                "毛の色",
                systemImage: "paintpalette.fill",
                tint: Palette.coral,
                wash: Palette.coralSoft
            )

            HStack(spacing: Spacing.small) {
                ForEach(model.species.coats, id: \.self) { coat in
                    choiceButton(
                        title: model.species.label(of: coat),
                        sample: Companion(
                            species: model.species,
                            coat: coat,
                            name: model.species.defaultName
                        ),
                        isSelected: model.coat == coat,
                        action: {
                            model.select(coat)
                        }
                    )
                }
            }
        }
        .roundedCard()
    }

    var nameField: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            CardLabel(
                "名前",
                systemImage: "pencil",
                tint: Palette.sunDeep,
                wash: Palette.sunSoft
            )

            TextField(model.species.defaultName, text: nameBinding)
                .font(.body.weight(.bold))
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, Spacing.medium)
                .frame(height: 48)
                .background(Palette.paper, in: .rect(cornerRadius: 16))

            if model.isNameTooLong {
                Text("名前は \(Companion.nameLimit) 字までです")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.coralDeep)
            }
        }
        .roundedCard()
    }

    func choiceButton(
        title: String,
        sample: Companion?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let fill = isSelected ? Palette.tealSoft : Palette.paper
        let stroke = isSelected ? Palette.teal : .clear
        let glow = isSelected ? Palette.teal.opacity(0.25) : .clear
        let pose = isSelected ? Companion.Pose.joy : .walk
        let ink = isSelected ? Palette.tealDeep : Palette.ink
        let scale = isSelected ? 1.04 : 1
        let traits: AccessibilityTraits = isSelected ? .isSelected : []

        return Button(action: action) {
            VStack(spacing: 4) {
                if let sample {
                    CompanionSticker(
                        companion: sample,
                        pose: pose,
                        size: 44,
                        breathes: false
                    )
                    .accessibilityHidden(true)
                }

                Text(title)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, Spacing.small)
            .frame(maxWidth: .infinity)
            .background(fill, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(stroke, lineWidth: 2)
            }
            .shadow(color: glow, radius: 6, y: 4)
            .scaleEffect(scale)
            .animation(.spring(duration: 0.4, bounce: 0.45), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(traits)
    }
}

private extension CompanionPickerForm {
    var nameBinding: Binding<String> {
        Binding(
            get: { model.name },
            set: { model.rename($0) }
        )
    }
}
