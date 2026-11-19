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
            }
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.medium)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            saveBar
        }
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

    var saveBar: some View {
        let dot = model.isChanged ? Palette.coral : Palette.teal

        return VStack(spacing: Spacing.small) {
            HStack(spacing: 6) {
                Circle()
                    .fill(dot)
                    .frame(width: 8, height: 8)

                Text(saveNote)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .contentTransition(.opacity)
            }

            Button {
                save()
            } label: {
                Label("この相棒にする", systemImage: "pawprint.fill")
            }
            .buttonStyle(.pill)
            .disabled(!model.canSave)
        }
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.small + 4)
        .padding(.bottom, Spacing.small)
        .frame(maxWidth: .infinity)
        .background(
            Palette.card,
            in: .rect(topLeadingRadius: 24, topTrailingRadius: 24)
        )
        .shadow(color: Palette.shadow, radius: 12, y: -4)
        .animation(.snappy, value: model.isChanged)
    }
}

private extension CompanionPickerView {
    var saveNote: String {
        if model.draft == nil {
            return "名前を入れると決められます"
        }

        return model.isChanged ? "まだ決めていません" : "今の相棒です"
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
