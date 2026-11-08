import FamilyControls
import SwiftUI

public struct BlockedAppsView: View {
    @Bindable private var model: SettingsModel

    @State private var isPickerPresented = false

    public init(model: SettingsModel) {
        _model = Bindable(model)
    }

    public var body: some View {
        List {
            Section {
                Text("旅の間、ここで選んだアプリを止めます。選び直すと、次の旅から変わります。")
            }

            Section("選んでいるアプリ") {
                ForEach(Array(model.selection.applicationTokens), id: \.self) { token in
                    Label(token)
                }

                ForEach(Array(model.selection.categoryTokens), id: \.self) { token in
                    Label(token)
                }
            }

            Section {
                Button("アプリを選ぶ") {
                    isPickerPresented = true
                }
                .disabled(isPickerDisabled)

                if model.isTripActive {
                    Text("旅の途中は選び直せません")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("止めるアプリ")
        .onAppear {
            model.refresh()
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
        .onChange(of: model.selection) {
            model.saveSelection()
        }
    }
}

private extension BlockedAppsView {
    var isPickerDisabled: Bool {
        model.isTripActive || !model.isAuthorized
    }
}
