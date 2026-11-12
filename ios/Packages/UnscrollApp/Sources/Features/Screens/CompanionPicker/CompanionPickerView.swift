import Core
import DesignSystem
import SwiftUI

public struct CompanionPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: CompanionPickerModel

    private let isFirstTime: Bool
    private let onSaved: () -> Void

    public init(
        model: CompanionPickerModel,
        isFirstTime: Bool,
        onSaved: @escaping () -> Void = {}
    ) {
        _model = State(initialValue: model)

        self.isFirstTime = isFirstTime
        self.onSaved = onSaved
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.large) {
                if isFirstTime {
                    header
                }

                preview

                speciesPicker

                coatPicker

                nameField

                Button {
                    save()
                } label: {
                    Text(buttonTitle)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(Palette.teal)
                .disabled(model.draft == nil)
            }
            .padding(Spacing.large)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(Palette.paper)
        .navigationTitle(navigationTitle)
    }
}

private extension CompanionPickerView {
    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("いっしょに旅する相棒")
                .font(.title.bold())
                .foregroundStyle(Palette.ink)

            Text("あとから設定で変えられます")
                .font(.subheadline)
                .foregroundStyle(Palette.muted)
        }
        .padding(.top, Spacing.large)
    }

    var preview: some View {
        VStack(spacing: Spacing.small + 4) {
            if let companion = model.preview {
                CompanionSticker(companion: companion, pose: .wave, size: 160)
            }

            Text(model.shownName)
                .font(.title3.bold())
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.large)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 24))
    }

    var speciesPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            label("種")

            Picker("種", selection: speciesBinding) {
                ForEach(Companion.Species.allCases, id: \.self) { species in
                    Text(species.label)
                        .tag(species)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var coatPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            label("毛の色")

            HStack(spacing: Spacing.small) {
                ForEach(model.species.coats, id: \.self) { coat in
                    coatButton(coat)
                }
            }
        }
    }

    var nameField: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            label("名前")

            TextField(model.species.defaultName, text: nameBinding)
                .font(.body)
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, Spacing.medium)
                .frame(height: 48)
                .background(Palette.card, in: RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Palette.muted.opacity(0.3), lineWidth: 1)
                }

            if model.isNameTooLong {
                Text("名前は \(Companion.nameLimit) 字までです")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    func label(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Palette.muted)
    }

    func coatButton(_ coat: Companion.Coat) -> some View {
        let isSelected = model.coat == coat
        let shape = RoundedRectangle(cornerRadius: 12)
        let species = model.species
        let sample = Companion(species: species, coat: coat, name: species.defaultName)
        let fill = isSelected ? Palette.teal.opacity(0.12) : Palette.card
        let stroke = isSelected ? Palette.teal : Palette.muted.opacity(0.3)
        let lineWidth: CGFloat = isSelected ? 2 : 1
        let traits: AccessibilityTraits = isSelected ? .isSelected : []

        return Button {
            model.select(coat)
        } label: {
            VStack(spacing: 4) {
                if let sample {
                    CompanionSticker(companion: sample, pose: .walk, size: 48, breathes: false)
                        .accessibilityHidden(true)
                }

                Text(species.label(of: coat))
                    .font(.caption)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, Spacing.small)
            .frame(maxWidth: .infinity)
            .background(fill, in: shape)
            .overlay {
                shape.stroke(stroke, lineWidth: lineWidth)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(species.label(of: coat))
        .accessibilityAddTraits(traits)
    }
}

private extension CompanionPickerView {
    var speciesBinding: Binding<Companion.Species> {
        Binding(
            get: { model.species },
            set: { model.select($0) }
        )
    }

    var nameBinding: Binding<String> {
        Binding(
            get: { model.name },
            set: { model.rename($0) }
        )
    }

    var navigationTitle: String {
        isFirstTime ? "" : "相棒"
    }

    var buttonTitle: String {
        isFirstTime ? "\(model.shownName)と旅に出る" : "この相棒にする"
    }

    func save() {
        guard model.save() else {
            return
        }

        onSaved()
        dismiss()
    }
}
