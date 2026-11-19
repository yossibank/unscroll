import DesignSystem
import SwiftUI

struct AppSetNameSheet: View {
    @State private var name: String

    @FocusState private var isFocused: Bool

    private let isRenaming: Bool
    private let onCommit: (String) -> Void
    private let onCancel: () -> Void

    init(
        name: String,
        isRenaming: Bool,
        onCommit: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _name = State(initialValue: name)

        self.isRenaming = isRenaming
        self.onCommit = onCommit
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            MaskingTape(tint: Palette.sun)
                .rotationEffect(.degrees(-4))

            JournalTitle(title, note: "旅の間に止めるアプリのまとまり")

            field

            suggestions

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Button(commitTitle) {
                    onCommit(name)
                }
                .buttonStyle(.pill)

                Button("やめる") {
                    onCancel()
                }
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, Spacing.large)
        .padding(.top, Spacing.large)
        .padding(.bottom, Spacing.small)
        .background(PaperBackdrop())
        .onAppear {
            isFocused = true
        }
    }
}

private extension AppSetNameSheet {
    static let examples = ["仕事中", "勉強中", "ゲーム", "夜ふかし"]

    var title: String {
        isRenaming ? "名前を変えよう" : "名前を付けよう"
    }

    var commitTitle: String {
        isRenaming ? "この名前にする" : "アプリを選んで作る"
    }

    var field: some View {
        TextField("例：勉強中", text: $name)
            .font(.title3.weight(.heavy))
            .foregroundStyle(Palette.ink)
            .focused($isFocused)
            .submitLabel(.done)
            .onSubmit {
                onCommit(name)
            }
            .padding(.horizontal, Spacing.medium)
            .frame(height: 56)
            .background(Palette.card, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Palette.teal.opacity(0.5), lineWidth: 2)
            }
    }

    var suggestions: some View {
        HStack(spacing: Spacing.small) {
            ForEach(Self.examples, id: \.self) { example in
                suggestion(example)
            }
        }
    }

    func suggestion(_ example: String) -> some View {
        let isChosen = name == example
        let fill = isChosen ? Palette.tealSoft : Palette.card
        let border = isChosen ? Palette.teal : Palette.paperDeep

        return Button {
            name = example
        } label: {
            Text(example)
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.small + 4)
                .frame(height: 32)
                .background(fill, in: Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(border, lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
    }
}
