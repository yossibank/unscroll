import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct TodayUsageView: View {
    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            VStack(alignment: .leading, spacing: 2) {
                total

                if let comparison {
                    Label(comparison.text, systemImage: comparison.symbol)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(comparison.tint)
                }
            }

            hourBars

            if !usage.categories.isEmpty {
                categoryStrip
            }

            HStack(spacing: Spacing.small) {
                fact(
                    "\(usage.pickups) 回",
                    note: "手に取った",
                    wash: Palette.sunSoft
                )

                fact(
                    firstPickupText,
                    note: "最初に見た",
                    wash: Palette.coralSoft
                )

                fact(
                    "\(usage.notifications) 件",
                    note: "通知",
                    wash: Palette.plumSoft
                )
            }

            if usage.apps.isEmpty {
                Text("まだ記録がありません")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Palette.muted)
            }

            VStack(spacing: Spacing.small) {
                ForEach(Array(usage.apps.prefix(3).enumerated()), id: \.element.id) { index, app in
                    appRow(app, tint: Self.appTints[index % Self.appTints.count])
                }
            }

            journeyNote

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

private extension TodayUsageView {
    static let appTints = [Palette.coral, Palette.sky, Palette.plum]
    static let categoryTints = [Palette.coral, Palette.sky, Palette.plum, Palette.sunDeep]
    static let barHeight: CGFloat = 56
    static let axisWidth: CGFloat = 28
    static let hourLength: TimeInterval = 60 * 60

    var busiest: (hour: Int, minutes: Int)? {
        guard
            let peak = usage.hours.max(),
            peak >= 60,
            let hour = usage.hours.firstIndex(of: peak)
        else {
            return nil
        }

        return (hour, Int(peak / 60))
    }

    var comparison: (text: String, symbol: String, tint: Color)? {
        guard let yesterday = usage.yesterdayTotal else {
            return nil
        }

        let difference = Int((usage.total - yesterday) / 60)

        if difference == 0 {
            return ("昨日の同じ時刻と同じくらい", "equal", Palette.muted)
        }

        if difference < 0 {
            return ("昨日の同じ時刻より \(-difference) 分少ない", "arrow.down", Palette.tealDeep)
        }

        return ("昨日の同じ時刻より \(difference) 分多い", "arrow.up", Palette.coralDeep)
    }

    var categoryStrip: some View {
        let named = usage.categories.filter { $0.name != CategoryUsage.otherName }
        let shown = Array(named.prefix(3))
        let shownNames = Set(shown.map(\.name))
        let rest = usage.categories
            .filter { !shownNames.contains($0.name) }
            .reduce(0) { $0 + $1.duration }
        let other = rest > 0 ? [(CategoryUsage.otherName, rest)] : []
        let parts = shown.map { ($0.name, $0.duration) } + other
        let sum = max(parts.reduce(0) { $0 + $1.1 }, 1)

        return VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    ForEach(parts.indices, id: \.self) { index in
                        Self.categoryTints[index % Self.categoryTints.count]
                            .frame(width: max(4, (proxy.size.width - 6) * parts[index].1 / sum))
                    }
                }
                .clipShape(Capsule())
            }
            .frame(height: 10)

            HStack(spacing: Spacing.small) {
                ForEach(parts.indices, id: \.self) { index in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Self.categoryTints[index % Self.categoryTints.count])
                            .frame(width: 8, height: 8)

                        Text("\(parts[index].0) \(Int((parts[index].1 / sum * 100).rounded()))%")
                            .font(.caption2.weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    var total: some View {
        let parts = Duration.seconds(usage.total).components
        let hours = parts.seconds / 3600
        let minutes = (parts.seconds % 3600) / 60

        return HStack(alignment: .lastTextBaseline, spacing: 2) {
            if hours > 0 {
                Text("\(hours)")
                    .font(.system(size: 36, weight: .heavy))

                Text("時間")
                    .font(.footnote.weight(.heavy))
                    .foregroundStyle(Palette.muted)
                    .padding(.trailing, 4)
            }

            Text("\(minutes)")
                .font(.system(size: 36, weight: .heavy))

            Text("分")
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.muted)
        }
        .monospacedDigit()
        .accessibilityElement(children: .combine)
    }

    var hourBars: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let busiest {
                Text("\(busiest.hour) 時台に一番使った（\(busiest.minutes) 分）")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Palette.muted)
            }

            HStack(alignment: .bottom, spacing: 2) {
                ForEach(usage.hours.indices, id: \.self) { hour in
                    let ratio = min(usage.hours[hour] / Self.hourLength, 1)

                    UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                        .fill(ratio > 0 ? tint(forHour: hour) : Palette.paperDeep)
                        .frame(height: max(3, Self.barHeight * ratio))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: Self.barHeight, alignment: .bottom)
            .padding(.trailing, Self.axisWidth)
            .background(alignment: .top) {
                VStack(spacing: 0) {
                    guide("60分")

                    Spacer(minLength: 0)

                    guide("30分")

                    Spacer(minLength: 0)
                }
            }

            HStack {
                ForEach(["0時", "6", "12", "18", "24"], id: \.self) { label in
                    Text(label)

                    if label != "24" {
                        Spacer()
                    }
                }
            }
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Palette.muted)
            .padding(.trailing, Self.axisWidth)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    var journeyNote: some View {
        let kilometers = Int(usage.total / 60) * Trip.kilometersPerMinute

        if kilometers > 0 {
            HStack(spacing: Spacing.small) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Palette.teal, in: Circle())

                Text(journeyText(kilometers))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.tealDeep)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.tealSoft, in: .rect(cornerRadius: 16))
        }
    }

    func guide(_ label: String) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(Palette.muted.opacity(0.2))
                .frame(height: 1)

            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Palette.muted)
                .frame(width: Self.axisWidth - 4, alignment: .trailing)
        }
        .frame(height: 10)
        .offset(y: -5)
    }

    func fact(
        _ value: String,
        note: String,
        wash: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.heavy))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(note)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Palette.muted)
        }
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(wash, in: .rect(cornerRadius: 16))
    }

    func appRow(
        _ app: AppUsage,
        tint: Color
    ) -> some View {
        let peak = max(usage.apps.first?.duration ?? 1, 1)

        return HStack(spacing: Spacing.small) {
            icon(for: app, tint: tint)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.caption.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                GeometryReader { proxy in
                    Capsule()
                        .fill(Palette.paperDeep)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(tint)
                                .frame(width: proxy.size.width * app.duration / peak)
                        }
                }
                .frame(height: 8)
            }

            Text(format(app.duration))
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.muted)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    func icon(
        for app: AppUsage,
        tint: Color
    ) -> some View {
        if let token = app.token {
            Label(token)
                .labelStyle(.iconOnly)
                .frame(width: 28, height: 28)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(tint)
                .frame(width: 28, height: 28)
        }
    }
}

private extension TodayUsageView {
    var firstPickupText: String {
        guard let firstPickup = usage.firstPickup else {
            return "-"
        }

        return firstPickup.formatted(date: .omitted, time: .shortened)
    }

    func tint(forHour hour: Int) -> Color {
        switch hour {
        case 5..<11: Palette.sun
        case 11..<18: Palette.sky
        default: Palette.plum
        }
    }

    func journeyText(_ kilometers: Int) -> String {
        let reached = Journey.tokyoToKyoto.landmarks.last {
            $0.kilometer > 0 && $0.kilometer <= kilometers
        }

        guard let reached else {
            return "この時間を旅にすると \(kilometers.formatted()) km 進めたよ"
        }

        return "この時間を旅にすると \(kilometers.formatted()) km。\(reached.name)まで行けたよ"
    }

    func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }
}
