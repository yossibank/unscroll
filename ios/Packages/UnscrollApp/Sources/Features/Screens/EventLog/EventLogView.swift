import DesignSystem
import SwiftUI

public struct EventLogView: View {
    @State private var model: SettingsModel

    public init(model: SettingsModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            if model.logLines.isEmpty {
                Text("まだありません")
                    .foregroundStyle(.secondary)
            }

            ForEach(Array(model.logLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.caption.monospaced())
            }

            HStack(spacing: Spacing.medium) {
                Button("読み直す") {
                    model.refresh()
                }

                Spacer()

                Button("消す", role: .destructive) {
                    model.clearLog()
                }
            }
            .buttonStyle(.borderless)
        }
        .navigationTitle("記録")
    }
}
