import DesignSystem
import FamilyControls
import SwiftUI

struct AppSetTags: View {
    @Bindable var model: SettingsModel

    @State private var isNaming = false
    @State private var isPickerPresented = false
    @State private var wantsPicker = false
    @State private var renamingID: UUID?
    @State private var nameDraft = ""

    var hidesEmpty = false

    let onChange: () -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.small) {
                ForEach(Array(shownSets.enumerated()), id: \.element.id) { index, set in
                    tag(set, index: index)
                }

                if model.canAddSet {
                    addTag
                }
            }
            .padding(.vertical, Spacing.small)
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .sheet(
            isPresented: $isNaming,
            onDismiss: {
                isPickerPresented = wantsPicker
                wantsPicker = false
            },
            content: {
                AppSetNameSheet(
                    name: nameDraft,
                    isRenaming: renamingID != nil,
                    onCommit: { name in
                        commitName(name)
                    },
                    onCancel: {
                        isNaming = false
                    }
                )
                .presentationDetents([.height(420)])
                .presentationCornerRadius(28)
            }
        )
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
        .onChange(of: model.selection) {
            model.saveSelection()
            onChange()
        }
    }
}

private extension AppSetTags {
    var addTag: some View {
        Button {
            startNaming(nil)
        } label: {
            Label("新しく作る", systemImage: "plus")
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.teal)
                .padding(.leading, Spacing.medium + 4)
                .padding(.trailing, Spacing.medium)
                .frame(height: 40)
                .overlay {
                    LuggageTagShape()
                        .stroke(
                            Palette.teal.opacity(0.6),
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                        )
                }
        }
        .buttonStyle(.plain)
    }

    func tag(
        _ set: BlockedAppSet,
        index: Int
    ) -> some View {
        let isActive = set.id == model.activeSetID
        let fill = isActive ? Palette.teal : Palette.card
        let ink = isActive ? Palette.card : Palette.ink
        let border = isActive ? Palette.tealDeep : Palette.paperDeep
        let tilt = index.isMultiple(of: 2) ? -2.0 : 1.5
        let traits: AccessibilityTraits = isActive ? .isSelected : []

        return Button {
            model.selectSet(set.id)
            onChange()
        } label: {
            HStack(spacing: 4) {
                if isActive {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.black))
                }

                Text(set.name)
                    .font(.footnote.weight(.heavy))
                    .lineLimit(1)
                    .fixedSize()
            }
            .foregroundStyle(ink)
            .padding(.leading, Spacing.medium + 4)
            .padding(.trailing, Spacing.medium)
            .frame(height: 40)
            .background(fill, in: LuggageTagShape())
            .overlay {
                LuggageTagShape()
                    .stroke(border, lineWidth: 1.5)
            }
            .shadow(color: Palette.shadow, radius: 3, y: 2)
            .rotationEffect(.degrees(tilt))
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
                    onChange()
                }
            }
        }
    }
}

private extension AppSetTags {
    var shownSets: [BlockedAppSet] {
        hidesEmpty ? model.sets.filter { !BlockedApps.isEmpty($0.selection) } : model.sets
    }

    func startNaming(_ set: BlockedAppSet?) {
        renamingID = set?.id
        nameDraft = set?.name ?? ""
        isNaming = true
    }

    func commitName(_ name: String) {
        if let renamingID {
            model.renameSet(renamingID, to: name)
        } else {
            model.addSet(named: name)
            onChange()
            wantsPicker = model.isAuthorized
        }

        isNaming = false
    }
}
