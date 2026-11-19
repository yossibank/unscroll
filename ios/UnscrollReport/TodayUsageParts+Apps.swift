import DesignSystem
import FamilyControls
import SwiftUI

struct AppIcon: View {
    let app: AppUsage
    let tint: Color

    var body: some View {
        if let token = app.token {
            Label(token)
                .labelStyle(.iconOnly)
                .scaleEffect(1.4)
                .frame(width: 28, height: 28)
        } else {
            RoundedRectangle(cornerRadius: 7)
                .fill(tint)
                .frame(width: 28, height: 28)
        }
    }
}

struct AppRow<Icon: View>: View {
    let name: String
    let value: String
    let ratio: Double
    let tint: Color
    @ViewBuilder let icon: Icon

    var body: some View {
        HStack(spacing: Spacing.small) {
            icon

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: Spacing.small) {
                    Text(name)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 0)

                    Text(value)
                        .foregroundStyle(Palette.muted)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .font(.footnote.weight(.bold))

                GeometryReader { proxy in
                    Capsule()
                        .fill(Palette.paperDeep)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(tint)
                                .frame(width: proxy.size.width * ratio)
                        }
                }
                .frame(height: 8)
            }
        }
    }
}

struct UsageAppList: View {
    let usage: TodayUsage
    let sort: UsageSort

    private let tints = [Palette.coral, Palette.sky, Palette.plum, Palette.sun, Palette.muted]

    var body: some View {
        let ranked = usage.apps.sorted { sort.value(of: $0) > sort.value(of: $1) }
        let shown = Array(ranked.prefix(5))
        let rest = Array(ranked.dropFirst(5))
        let peak = ranked.first.map { sort.value(of: $0) } ?? 0

        VStack(alignment: .leading, spacing: Spacing.small) {
            UsageSectionHeader(sort.heading, trailing: sort.total(of: usage))

            VStack(spacing: Spacing.small) {
                ForEach(Array(shown.enumerated()), id: \.element.id) { index, app in
                    AppRow(
                        name: app.name,
                        value: sort.text(sort.value(of: app)),
                        ratio: ratio(sort.value(of: app), peak: peak),
                        tint: tint(at: index)
                    ) {
                        AppIcon(app: app, tint: tint(at: index))
                    }
                }

                if !rest.isEmpty {
                    otherRow(rest, peak: peak)
                }

                ForEach(0..<emptySlots(shown: shown, rest: rest), id: \.self) { _ in
                    emptyRow
                }
            }
        }
    }
}

private extension UsageAppList {
    static let slotCount = 6

    var emptyRow: some View {
        HStack(spacing: Spacing.small) {
            RoundedRectangle(cornerRadius: 7)
                .strokeBorder(Palette.paperDeep, style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                .frame(width: 28, height: 28)

            Capsule()
                .fill(Palette.paperDeep.opacity(0.6))
                .frame(height: 8)
        }
    }

    func otherRow(
        _ rest: [AppUsage],
        peak: Double
    ) -> some View {
        let sum = sort == .perPickup ? 0 : rest.reduce(0) { $0 + sort.value(of: $1) }

        return AppRow(
            name: "その他 \(rest.count) アプリ",
            value: sort.text(sum),
            ratio: ratio(sum, peak: peak),
            tint: sort == .time ? Palette.muted : sort.tint
        ) {
            RoundedRectangle(cornerRadius: 7)
                .fill(Palette.paperDeep)
                .frame(width: 28, height: 28)
                .overlay {
                    Text("…")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Palette.muted)
                }
        }
    }

    func emptySlots(
        shown: [AppUsage],
        rest: [AppUsage]
    ) -> Int {
        let filled = shown.count + (rest.isEmpty ? 0 : 1)
        return max(Self.slotCount - filled, 0)
    }

    func tint(at index: Int) -> Color {
        sort == .time ? tints[index % tints.count] : sort.tint
    }

    func ratio(
        _ value: Double,
        peak: Double
    ) -> Double {
        peak > 0 ? min(value / peak, 1) : 0
    }
}
