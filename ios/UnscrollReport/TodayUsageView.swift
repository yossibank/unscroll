import FamilyControls
import Foundation
import SwiftUI

struct TodayUsageView: View {
    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("今日の使用時間")
                    .font(.headline)

                Spacer()

                Text(format(usage.total))
                    .font(.title2.bold())
                    .monospacedDigit()
            }

            if usage.apps.isEmpty {
                Text("まだ記録がありません")
                    .foregroundStyle(.secondary)
            }

            ForEach(usage.apps.prefix(8)) { app in
                HStack {
                    icon(for: app)

                    Text(app.name)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text(format(app.duration))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
    }
}

private extension TodayUsageView {
    @ViewBuilder
    func icon(for app: AppUsage) -> some View {
        if let token = app.token {
            Label(token)
                .labelStyle(.iconOnly)
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: "app.dashed")
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
        }
    }

    func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }
}
