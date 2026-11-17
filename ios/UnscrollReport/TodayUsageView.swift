import DesignSystem
import SwiftUI

struct TodayUsageView: View {
    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            UsageHeadline(usage: usage)

            HStack(spacing: Spacing.small) {
                UsageFact(
                    "\(usage.pickups) 回",
                    note: "手に取った",
                    wash: Palette.sunSoft
                )

                UsageFact(
                    usage.perPickup ?? "-",
                    note: "1 回あたり",
                    wash: Palette.skySoft
                )

                UsageFact(
                    "\(usage.notifications) 件",
                    note: "通知",
                    wash: Palette.plumSoft
                )

                UsageFact(
                    usage.firstPickupText,
                    note: "最初に見た",
                    wash: Palette.coralSoft
                )
            }

            HourBars(values: usage.hours, unit: .time)

            if usage.total == 0 {
                Text("まだ記録がありません")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }

            JourneyNote(usage: usage)

            Spacer(minLength: 0)
        }
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}
