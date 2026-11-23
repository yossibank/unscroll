import DesignSystem
import FamilyControls
import SwiftUI

struct UsageAppList: View {
    let usage: TodayUsage
    let sort: UsageSort

    private let tints = [Palette.coral, Palette.sky, Palette.plum, Palette.sun, Palette.muted]

    var body: some View {
        let ranked = usage.apps.sorted { sort.value(of: $0) > sort.value(of: $1) }
        let shown = Array(ranked.prefix(Self.slotCount))
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

                ForEach(0..<max(Self.slotCount - shown.count, 0), id: \.self) { _ in
                    emptyRow
                }
            }
        }
    }
}

private extension UsageAppList {
    static let slotCount = 5

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
