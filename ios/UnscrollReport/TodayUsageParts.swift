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
            return ("昨日の同じ時刻より \(-difference) 分少ないです", "arrow.down", Palette.tealDeep)
        }

        return ("昨日の同じ時刻より \(difference) 分多いです", "arrow.up", Palette.coralDeep)
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
        guard total > 0 else {
            return nil
        }

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
        VStack(alignment: .leading, spacing: Spacing.small) {
            UsageTotal(usage: usage)

            Label(comparison.text, systemImage: comparison.symbol)
                .font(.caption.weight(.heavy))
                .foregroundStyle(comparison.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.small + 4)
                .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
                .background(comparison.tint.opacity(0.12), in: .rect(cornerRadius: 12))
        }
    }
}

private extension UsageHeadline {
    var comparison: (text: String, symbol: String, tint: Color) {
        usage.comparison ?? ("昨日の記録はまだありません", "clock", Palette.muted)
    }
}

struct UsageSectionHeader: View {
    let title: String
    let trailing: String?

    init(
        _ title: String,
        trailing: String? = nil
    ) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(title)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if let trailing {
                Text(trailing)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .font(.caption.weight(.bold))
    }
}

struct CategoryStrip: View {
    static let legendCount = 4

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
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.paperDeep)
                .clipShape(Capsule())
            }
            .frame(height: 10)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<Self.legendCount, id: \.self) { index in
                    if index < parts.count {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(tints[index % tints.count])
                                .frame(width: 8, height: 8)

                            Text(
                                "\(parts[index].0) \(Int((parts[index].1 / sum * 100).rounded()))%"
                            )
                            .font(.caption2.weight(.bold))
                        }
                    } else {
                        Text(index == 0 ? "まだ記録がありません" : " ")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Palette.muted)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct JourneyNote: View {
    let usage: TodayUsage

    var body: some View {
        let kilometers = Int(usage.total / 60) * Trip.kilometersPerMinute

        HStack(spacing: Spacing.small) {
            Image(systemName: "figure.walk")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Palette.teal, in: Circle())

            Text(usage.journeyText(kilometers))
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.tealDeep)
                .lineLimit(2, reservesSpace: true)
                .minimumScaleFactor(0.8)
        }
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.tealSoft, in: .rect(cornerRadius: 16))
    }
}
