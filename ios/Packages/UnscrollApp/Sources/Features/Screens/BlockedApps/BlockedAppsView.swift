import DesignSystem
import FamilyControls
import SwiftUI

public struct BlockedAppsView: View {
    @Bindable private var model: SettingsModel

    @State private var isPickerPresented = false
    @State private var isNaming = false
    @State private var renamingID: UUID?
    @State private var nameDraft = ""

    public init(model: SettingsModel) {
        _model = Bindable(model)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Label(
                    "旅の間、ここで選んだアプリを止めます。選び直すと、次の旅から変わります。",
                    systemImage: "hand.raised.fill"
                )
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.coralDeep)
                .roundedCard(fill: LinearGradient(
                    colors: [Palette.coralSoft, Palette.card],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

                setChips

                selectedCard

                Button {
                    isPickerPresented = true
                } label: {
                    Label("アプリを選ぶ", systemImage: "plus.app.fill")
                }
                .buttonStyle(.pill)
                .disabled(isPickerDisabled)

                if model.isTripActive {
                    Text("旅の途中は選び直せません")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.muted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(Spacing.medium)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(PaperBackdrop())
        .navigationTitle("止めるアプリ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            model.refresh()
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
        .onChange(of: model.selection) {
            model.saveSelection()
        }
        .alert(namingTitle, isPresented: $isNaming) {
            TextField("名前", text: $nameDraft)

            Button("キャンセル", role: .cancel) {}

            Button("決める") {
                commitName()
            }
        }
    }
}

private extension BlockedAppsView {
    var setChips: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.small) {
                ForEach(model.sets) { set in
                    setChip(set)
                }

                if model.canAddSet {
                    Button {
                        startNaming(nil)
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(Palette.teal)
                            .frame(width: 40, height: 40)
                            .background(Palette.card, in: Circle())
                            .overlay {
                                Circle()
                                    .strokeBorder(Palette.paperDeep, lineWidth: 1.5)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("組を足す")
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .disabled(model.isTripActive)
    }

    var selectedCard: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            CardLabel(
                model.activeSetName,
                systemImage: "app.badge.fill",
                tint: Palette.teal,
                wash: Palette.tealSoft
            ) {
                Text(model.selectionSummary)
                    .foregroundStyle(Palette.muted)
            }

            if isEmpty {
                Text("まだ選んでいません")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Palette.paper, in: .rect(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: Spacing.small) {
                ForEach(Array(model.selection.applicationTokens), id: \.self) { token in
                    Label(token)
                        .font(.subheadline.weight(.bold))
                }

                ForEach(Array(model.selection.categoryTokens), id: \.self) { token in
                    Label(token)
                        .font(.subheadline.weight(.bold))
                }
            }
        }
        .roundedCard()
    }

    func setChip(_ set: BlockedAppSet) -> some View {
        let isActive = set.id == model.activeSetID
        let fill = isActive ? Palette.teal : Palette.card
        let ink = isActive ? Palette.card : Palette.ink
        let border = isActive ? Palette.teal : Palette.paperDeep
        let traits: AccessibilityTraits = isActive ? .isSelected : []

        return Button {
            model.selectSet(set.id)
        } label: {
            HStack(spacing: 4) {
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.heavy))
                }

                Text(set.name)
                    .font(.subheadline.weight(.heavy))
                    .lineLimit(1)
                    .fixedSize()
            }
            .foregroundStyle(ink)
            .padding(.horizontal, Spacing.medium)
            .frame(height: 40)
            .background(fill, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(border, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(traits)
        .contextMenu {
            Button("名前を変える", systemImage: "pencil") {
                startNaming(set)
            }

            if model.sets.count > 1 {
                Button("消す", systemImage: "trash", role: .destructive) {
                    model.deleteSet(set.id)
                }
            }
        }
    }
}

private extension BlockedAppsView {
    var namingTitle: String {
        renamingID == nil ? "組を足す" : "名前を変える"
    }

    var isPickerDisabled: Bool {
        model.isTripActive || !model.isAuthorized
    }

    var isEmpty: Bool {
        model.selection.applicationTokens.isEmpty && model.selection.categoryTokens.isEmpty
    }

    func startNaming(_ set: BlockedAppSet?) {
        renamingID = set?.id
        nameDraft = set?.name ?? ""
        isNaming = true
    }

    func commitName() {
        if let renamingID {
            model.renameSet(renamingID, to: nameDraft)
        } else {
            model.addSet(named: nameDraft)
        }
    }
}
