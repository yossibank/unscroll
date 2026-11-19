import DesignSystem
import SwiftUI

struct TodayUsageView: View {
    @State private var sort = UsageSort.time

    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            UsageHeadline(usage: usage)

            facts

            flow

            UsageAppList(usage: usage, sort: sort)

            if !usage.categories.isEmpty {
                categories
            }

            JourneyNote(usage: usage)
        }
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .dynamicTypeSize(...DynamicTypeSize.large)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

private extension TodayUsageView {
    var busiestText: String {
        guard let busiest = usage.busiest else {
            return "まだ記録がありません"
        }

        return "\(busiest.hour) 時台がいちばん（\(busiest.minutes) 分）"
    }

    var facts: some View {
        HStack(spacing: Spacing.small) {
            UsageSortButton(
                "\(usage.pickups) 回",
                note: "手に取った",
                sort: .pickups,
                selection: $sort
            )

            UsageSortButton(
                usage.perPickup ?? "-",
                note: "1 回あたり",
                sort: .perPickup,
                selection: $sort
            )

            UsageSortButton(
                "\(usage.notifications) 件",
                note: "通知",
                sort: .notifications,
                selection: $sort
            )

            UsageFact(
                usage.firstPickupText,
                note: "最初に見た"
            )
        }
        .padding(.bottom, 6)
    }

    var flow: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            UsageSectionHeader("1 日の流れ", trailing: busiestText)

            HourBars(
                hours: usage.hours,
                peakHour: usage.busiest?.hour
            )

            if let rest = usage.longestRest {
                UsageRest(start: rest.start, length: rest.length)
            }
        }
    }

    var categories: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            UsageSectionHeader("使い方の内訳")

            CategoryStrip(categories: usage.categories)
        }
    }
}
