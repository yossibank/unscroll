import Core
import DesignSystem
import SwiftUI

public struct CompanionPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var model: CompanionPickerModel
    @State private var pose = Companion.Pose.wave

    private let onSaved: () -> Void

    public init(
        model: CompanionPickerModel,
        onSaved: @escaping () -> Void = {}
    ) {
        _model = State(initialValue: model)

        self.onSaved = onSaved
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                preview

                CompanionPickerForm(model: model)

                Button {
                    save()
                } label: {
                    Label("この相棒にする", systemImage: "pawprint.fill")
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
        .navigationTitle("相棒")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: model.preview) {
            await cheer(.jump)
        }
    }
}

private extension CompanionPickerView {
    var preview: some View {
        RoomScene(
            companion: model.preview,
            look: RoomLook(defaults: .standard),
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
}

private extension CompanionPickerView {
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
