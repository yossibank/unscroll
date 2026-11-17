import DesignSystem
import SwiftUI

struct TodayUsageView: View {
    @State private var tab = Tab.hours
    @State private var metric = Metric.time

    let usage: TodayUsage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.small + 4) {
                UsageHeadline(usage: usage)

                facts

                CapsulePicker(
                    Tab.allCases,
                    selection: $tab,
                    title: \.title
                )

                content
            }
            .fontDesign(.rounded)
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

private extension TodayUsageView {
    enum Tab: CaseIterable {
        case hours
        case apps
        case categories

        var title: String {
            switch self {
            case .hours: "時間ごと"
            case .apps: "アプリ"
            case .categories: "種類"
            }
        }
    }

    enum Metric: CaseIterable {
        case time
        case pickups
        case notifications

        var title: String {
            switch self {
            case .time: "使った時間"
            case .pickups: "手に取った回数"
            case .notifications: "通知"
            }
        }
    }

    static let appTints = [Palette.coral, Palette.sky, Palette.plum, Palette.sun, Palette.muted]

    var values: [Double] {
        switch metric {
        case .time: usage.hours
        case .pickups: usage.hourPickups.map(Double.init)
        case .notifications: usage.hourNotifications.map(Double.init)
        }
    }

    var facts: some View {
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
    }

    @ViewBuilder
    var content: some View {
        switch tab {
        case .hours: hoursContent
        case .apps: appsContent
        case .categories: categoriesContent
        }
    }

    @ViewBuilder
    var hoursContent: some View {
        if usage.total == 0 {
            emptyText
        } else {
            VStack(alignment: .leading, spacing: Spacing.small + 4) {
                CapsulePicker(
                    Metric.allCases,
                    selection: $metric,
                    title: \.title
                )

                HourBars(values: values, unit: metric == .time ? .time : .count)

                summaryBand
            }
        }
    }

    @ViewBuilder
    var appsContent: some View {
        if usage.apps.isEmpty {
            emptyText
        } else {
            VStack(spacing: Spacing.small + 4) {
                ForEach(
                    Array(usage.apps.prefix(5).enumerated()),
                    id: \.element.id
                ) { index, app in
                    AppRow(
                        app,
                        peak: usage.apps.first?.duration ?? 1,
                        tint: Self.appTints[index % Self.appTints.count]
                    ) {
                        badges(for: app)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var categoriesContent: some View {
        if usage.categories.isEmpty {
            emptyText
        } else {
            VStack(alignment: .leading, spacing: Spacing.small + 4) {
                CategoryStrip(categories: usage.categories)

                JourneyNote(usage: usage)
            }
        }
    }

    var emptyText: some View {
        Text("まだ記録がありません")
            .font(.footnote.weight(.bold))
            .foregroundStyle(Palette.muted)
    }

    @ViewBuilder
    var summaryBand: some View {
        let rest = usage.longestRest
        let busiest = usage.busiest

        if rest != nil || busiest != nil {
            VStack(alignment: .leading, spacing: 4) {
                if let rest {
                    Text(
                        "いちばん長く置いたのは \(rest.start)時〜\(rest.start + rest.length - 1)時台（\(rest.length) 時間）"
                    )
                }

                if let busiest {
                    Text("\(busiest.hour) 時台に一番使いました（\(busiest.minutes) 分）")
                }
            }
            .font(.caption.weight(.bold))
            .padding(Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.sunSoft, in: .rect(cornerRadius: 16))
        }
    }

    func badges(for app: AppUsage) -> some View {
        HStack(spacing: 6) {
            badge("\(app.pickups) 回", wash: Palette.sunSoft)

            badge("\(app.notifications) 件", wash: Palette.plumSoft)

            if app.pickups > 0 {
                let minutes = Int(app.duration / Double(app.pickups) / 60)

                badge(
                    minutes < 1 ? "1 回 1 分未満" : "1 回 \(minutes) 分",
                    wash: Palette.skySoft
                )
            }
        }
    }

    func badge(
        _ text: String,
        wash: Color
    ) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .monospacedDigit()
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(wash, in: Capsule())
    }
}
