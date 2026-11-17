import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

extension TodayUsage {
    var busiest: (hour: Int, minutes: Int)? {
        guard
            let peak = hours.max(),
            peak >= 60,
            let hour = hours.firstIndex(of: peak)
        else {
            return nil
        }

        return (hour, Int(peak / 60))
    }

    var comparison: (text: String, symbol: String, tint: Color)? {
        guard let yesterdayTotal else {
            return nil
        }

        let difference = Int((total - yesterdayTotal) / 60)

        if difference == 0 {
            return ("昨日の同じ時刻と同じくらい", "equal", Palette.muted)
        }

        if difference < 0 {
            return ("昨日の同じ時刻より \(-difference) 分少ない", "arrow.down", Palette.tealDeep)
        }

        return ("昨日の同じ時刻より \(difference) 分多い", "arrow.up", Palette.coralDeep)
    }

    var firstPickupText: String {
        guard let firstPickup else {
            return "-"
        }

        return firstPickup.formatted(date: .omitted, time: .shortened)
    }

    var perPickup: String? {
        guard pickups > 0 else {
            return nil
        }

        let minutes = Int(total / Double(pickups) / 60)

        return minutes < 1 ? "1 分未満" : "\(minutes) 分"
    }

    var longestRest: (start: Int, length: Int)? {
        let current = Calendar.current.component(.hour, from: .now)
        var best: (start: Int, length: Int)?
        var run: (start: Int, length: Int)?

        for hour in 0...min(current, hours.count - 1) {
            if hours[hour] == 0 {
                run = (run?.start ?? hour, (run?.length ?? 0) + 1)

                if let run, run.length > (best?.length ?? 0) {
                    best = run
                }
            } else {
                run = nil
            }
        }

        guard let best, best.length >= 1 else {
            return nil
        }

        return best
    }

    static func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
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
}

struct UsageTotal: View {
    let usage: TodayUsage

    var body: some View {
        let parts = Duration.seconds(usage.total).components
        let hours = parts.seconds / 3600
        let minutes = (parts.seconds % 3600) / 60

        HStack(alignment: .lastTextBaseline, spacing: 2) {
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
}

struct UsageHeadline: View {
    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            UsageTotal(usage: usage)

            if let comparison = usage.comparison {
                Label(comparison.text, systemImage: comparison.symbol)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(comparison.tint)
            }
        }
    }
}

struct UsageFact: View {
    let value: String
    let note: String
    let wash: Color

    init(
        _ value: String,
        note: String,
        wash: Color
    ) {
        self.value = value
        self.note = note
        self.wash = wash
    }

    var body: some View {
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
}

struct HourBars: View {
    enum Unit {
        case time
        case count
    }

    let values: [Double]
    let unit: Unit

    private let barHeight: CGFloat = 56
    private let axisWidth: CGFloat = 28
    private let hourLength: Double = 60 * 60

    var body: some View {
        let peak = max(values.max() ?? 0, 1)

        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(values.indices, id: \.self) { hour in
                    let ratio = unit == .time
                        ? min(values[hour] / hourLength, 1)
                        : values[hour] / peak

                    UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                        .fill(ratio > 0 ? Palette.hour(hour) : Palette.paperDeep)
                        .frame(height: max(3, barHeight * ratio))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: barHeight, alignment: .bottom)
            .padding(.trailing, axisWidth)
            .background(alignment: .top) {
                if unit == .time {
                    VStack(spacing: 0) {
                        guide("60分")

                        Spacer(minLength: 0)

                        guide("30分")

                        Spacer(minLength: 0)
                    }
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
            .padding(.trailing, axisWidth)
        }
        .accessibilityHidden(true)
    }

    private func guide(_ label: String) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(Palette.muted.opacity(0.2))
                .frame(height: 1)

            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Palette.muted)
                .frame(width: axisWidth - 4, alignment: .trailing)
        }
        .frame(height: 10)
        .offset(y: -5)
    }
}

struct CategoryStrip: View {
    let categories: [CategoryUsage]

    private let tints = [Palette.coral, Palette.sky, Palette.plum, Palette.sunDeep]

    var body: some View {
        let named = categories.filter { $0.name != CategoryUsage.otherName }
        let shown = Array(named.prefix(3))
        let shownNames = Set(shown.map(\.name))
        let rest = categories
            .filter { !shownNames.contains($0.name) }
            .reduce(0) { $0 + $1.duration }
        let other = rest > 0 ? [(CategoryUsage.otherName, rest)] : []
        let parts = shown.map { ($0.name, $0.duration) } + other
        let sum = max(parts.reduce(0) { $0 + $1.1 }, 1)

        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    ForEach(parts.indices, id: \.self) { index in
                        tints[index % tints.count]
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
                            .fill(tints[index % tints.count])
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
}

struct AppIcon: View {
    let app: AppUsage
    let tint: Color

    var body: some View {
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

struct AppRow<Badges: View>: View {
    let app: AppUsage
    let peak: TimeInterval
    let tint: Color
    let badges: Badges

    init(
        _ app: AppUsage,
        peak: TimeInterval,
        tint: Color,
        @ViewBuilder badges: () -> Badges
    ) {
        self.app = app
        self.peak = max(peak, 1)
        self.tint = tint
        self.badges = badges()
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            AppIcon(app: app, tint: tint)

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

                badges
            }

            Text(TodayUsage.format(app.duration))
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.muted)
                .monospacedDigit()
        }
    }
}

extension AppRow where Badges == EmptyView {
    init(
        _ app: AppUsage,
        peak: TimeInterval,
        tint: Color
    ) {
        self.init(app, peak: peak, tint: tint) {
            EmptyView()
        }
    }
}

struct JourneyNote: View {
    let usage: TodayUsage

    var body: some View {
        let kilometers = Int(usage.total / 60) * Trip.kilometersPerMinute

        if kilometers > 0 {
            HStack(spacing: Spacing.small) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Palette.teal, in: Circle())

                Text(usage.journeyText(kilometers))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.tealDeep)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.small)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.tealSoft, in: .rect(cornerRadius: 16))
        }
    }
}
