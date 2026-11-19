import DesignSystem
import FamilyControls
import SwiftUI

public struct BlockedAppsView: View {
    @Bindable private var model: SettingsModel

    @State private var isPickerPresented = false

    public init(model: SettingsModel) {
        _model = Bindable(model)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Label(
                    "旅の間、選んだおるす札のアプリを止めます。札は部屋のきっぷの上でも替えられます。",
                    systemImage: "hand.raised.fill"
                )
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.coralDeep)
                .roundedCard(fill: LinearGradient(
                    colors: [Palette.coralSoft, Palette.card],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

                AppSetTags(model: model) {}
                    .disabled(model.isTripActive)

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
    }
}

private extension BlockedAppsView {
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
}

private extension BlockedAppsView {
    var isPickerDisabled: Bool {
        model.isTripActive || !model.isAuthorized
    }

    var isEmpty: Bool {
        model.selection.applicationTokens.isEmpty && model.selection.categoryTokens.isEmpty
    }
}
