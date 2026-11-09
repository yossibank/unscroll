import Core
import DesignSystem
import DeviceActivity
import FamilyControls
import Store
import SwiftUI

public struct FocusPrototypeView: View {
    @State private var model: FocusPrototypeModel
    @State private var isPickerPresented = false

    @Environment(\.scenePhase) private var scenePhase

    public init(model: FocusPrototypeModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("1. 許可") {
                    LabeledContent("Screen Time", value: model.isAuthorized ? "許可あり" : "許可なし")

                    Button("許可を求める") {
                        Task {
                            await model.requestAuthorization()
                        }
                    }
                }

                Section("2. 止めるアプリ") {
                    Text(model.selectionSummary)

                    Button("アプリを選ぶ") {
                        isPickerPresented = true
                    }
                    .disabled(!model.isAuthorized)
                }

                focusSection

                Section {
                    Button("区切りの見張りを始める") {
                        model.startUsageWatch()
                    }
                    .disabled(!isReady)
                } header: {
                    Text("4. 使用時間の区切り")
                } footer: {
                    Text("選んだアプリを 1・5・15 分使うと、見張りの拡張が下の記録に書きます。")
                }

                Section("5. 今日の使用時間（OS が描く枠）") {
                    DeviceActivityReport(reportContext, filter: todayFilter)
                        .frame(height: 360)
                }

                logSection
            }
            .navigationTitle("Unscroll 試作")
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selection)
            .onChange(of: model.selection) {
                model.saveSelection()
            }
            .onChange(of: scenePhase) {
                model.refresh()
            }
            .refreshable {
                model.refresh()
            }
        }
    }
}

private extension FocusPrototypeView {
    var focusSection: some View {
        Section {
            LabeledContent("進んだ距離", value: "\(model.progress?.kilometers ?? 0) km")

            if let end = model.focusEndsAt {
                LabeledContent("終わる時刻", value: end.formatted(date: .omitted, time: .shortened))

                Button("やめる", role: .destructive) {
                    model.stopFocus()
                }
            } else {
                Button("25 分 集中する") {
                    model.startFocus(minutes: 25)
                }
                .disabled(!isReady)
            }
        } header: {
            Text("3. 集中")
        } footer: {
            Text("集中の間は、選んだアプリを開くと止めた画面が出ます。")
        }
    }

    var logSection: some View {
        Section("記録") {
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
    }
}

private extension FocusPrototypeView {
    var isReady: Bool {
        model.isAuthorized && model.hasSelection
    }

    var reportContext: DeviceActivityReport.Context {
        DeviceActivityReport.Context(ScreenTimeShared.reportContextName)
    }

    var todayFilter: DeviceActivityFilter {
        let today = Calendar.current.dateInterval(of: .day, for: .now) ?? DateInterval()

        return DeviceActivityFilter(
            segment: .daily(during: today),
            users: .all,
            devices: .init([.iPhone])
        )
    }
}

#Preview {
    if let database = try? AppDatabase.inMemory() {
        FocusPrototypeView(model: FocusPrototypeModel(database: database))
    }
}
