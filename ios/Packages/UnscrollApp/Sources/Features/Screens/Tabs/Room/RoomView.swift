import DesignSystem
import SwiftUI

public struct RoomView: View {
    @State private var model: RoomModel

    @Environment(\.scenePhase) private var scenePhase

    public init(model: RoomModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    distanceCard

                    tripCard

                    usageCard
                }
                .padding(Spacing.medium)
            }
            .background(Palette.paper)
            .navigationTitle("Unscroll")
            .onAppear {
                model.refresh()
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

private extension RoomView {
    static let routeKilometers = 500
}

private extension RoomView {
    var distanceCard: some View {
        let kilometers = model.progress?.kilometers ?? 0

        return card {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("進んだ距離")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                Text("\(kilometers) km")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.ink)

                Text("東京 → 京都")
                    .foregroundStyle(Palette.ink)

                Text("あと \(max(0, Self.routeKilometers - kilometers)) km")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    var tripCard: some View {
        card {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Text("旅")
                        .font(.subheadline)
                        .foregroundStyle(Palette.muted)

                    if let end = model.tripEndsAt {
                        activeTrip(end: end)
                    } else {
                        idleTrip
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ProvisionalMark()
            }
        }
    }

    var usageCard: some View {
        card {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Text("今日のスマホ")
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)

                UsageReportView()
                    .frame(height: 240)
            }
        }
    }

    var idleTrip: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Button {
                model.startTrip(minutes: 25)
            } label: {
                Text("25 分 旅に出す")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Palette.teal)
            .disabled(!model.canStart)

            if !model.isAuthorized || !model.hasSelection {
                Text("設定で、許可と止めるアプリを選んでください")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    func activeTrip(end: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            LabeledContent("終わる時刻", value: end.formatted(date: .omitted, time: .shortened))
                .foregroundStyle(Palette.ink)

            TimelineView(.periodic(from: .now, by: 30)) { context in
                let minutes = max(0, Int(ceil(end.timeIntervalSince(context.date) / 60)))

                Text("あと \(minutes) 分")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Palette.ink)
            }

            Button("やめる（進んだ分は残る）", role: .destructive) {
                model.stopTrip()
            }
        }
    }

    func card(
        @ViewBuilder content: () -> some View
    ) -> some View {
        content()
            .padding(Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
    }
}
