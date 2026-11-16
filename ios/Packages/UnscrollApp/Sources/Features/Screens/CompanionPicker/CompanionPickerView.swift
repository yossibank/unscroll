import Core
import DesignSystem
import SwiftUI

public struct CompanionPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: CompanionPickerModel
    @State private var pose = Companion.Pose.wave

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
            VStack(alignment: .leading, spacing: Spacing.medium) {
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
                    Label(buttonTitle, systemImage: "pawprint.fill")
                }
                .buttonStyle(.pill)
                .disabled(model.draft == nil)
                .padding(.top, Spacing.small)
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.medium)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(PaperBackdrop())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: model.preview) {
            await cheer(.jump)
        }
    }
}

private extension CompanionPickerView {
    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("いっしょに旅する相棒")
                .font(.title.weight(.heavy))
                .foregroundStyle(Palette.ink)

            Text("あとから設定で変えられます")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.muted)
        }
        .padding(.top, Spacing.large)
    }

    var preview: some View {
        RoomScene(
            companion: model.preview,
            pose: pose,
            window: Journey.tokyoToKyoto.nextLandmark(after: 0),
            postcards: [],
            nextRemaining: nil,
            souvenirs: [],
            onPoke: {
                Task {
                    await cheer(.joy)
                }
            }
        )
        .overlay(alignment: .bottomLeading) {
            Text(model.shownName)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.small + 4)
                .padding(.vertical, 4)
                .background(.white.opacity(0.92), in: Capsule())
                .padding(Spacing.small + 4)
                .allowsHitTesting(false)
                .contentTransition(.opacity)
                .animation(.snappy, value: model.shownName)
        }
        .clipShape(.rect(cornerRadius: RoundedCard.radius))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
    }

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
        let traits: AccessibilityTraits = isSelected ? .isSelected : []

        return Button(action: action) {
            VStack(spacing: 4) {
                if let sample {
                    CompanionSticker(
                        companion: sample,
                        pose: isSelected ? .joy : .walk,
                        size: 44,
                        breathes: false
                    )
                    .accessibilityHidden(true)
                }

                Text(title)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(isSelected ? Palette.tealDeep : Palette.ink)
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
            .scaleEffect(isSelected ? 1.04 : 1)
            .animation(.spring(duration: 0.4, bounce: 0.45), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(traits)
    }
}

private extension CompanionPickerView {
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

    func cheer(_ reaction: Companion.Pose) async {
        pose = reaction

        try? await Task.sleep(for: .seconds(0.6))

        pose = .wave
    }

    func save() {
        guard model.save() else {
            return
        }

        onSaved()
        dismiss()
    }
}
