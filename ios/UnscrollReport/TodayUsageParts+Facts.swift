import Core
import DesignSystem
import SwiftUI

extension UsageSort {
    var tint: Color {
        switch self {
        case .time: Palette.muted
        case .pickups: Palette.sun
        case .perPickup: Palette.sky
        case .notifications: Palette.plum
        }
    }

    var deep: Color {
        switch self {
        case .time: Palette.muted
        case .pickups: Palette.sunDeep
        case .perPickup: Palette.skyDeep
        case .notifications: Palette.plumDeep
        }
    }

    var soft: Color {
        switch self {
        case .time: Palette.paperDeep
        case .pickups: Palette.sunSoft
        case .perPickup: Palette.skySoft
        case .notifications: Palette.plumSoft
        }
    }

    var heading: String {
        switch self {
        case .time: "よく使ったアプリ"
        case .pickups: "手に取った回数が多いアプリ"
        case .perPickup: "1 回が長いアプリ"
        case .notifications: "通知が多いアプリ"
        }
    }

    func value(of app: AppUsage) -> Double {
        switch self {
        case .time: app.duration
        case .pickups: Double(app.pickups)
        case .perPickup: app.pickups > 0 ? app.duration / Double(app.pickups) : 0
        case .notifications: Double(app.notifications)
        }
    }

    func text(_ value: Double) -> String {
        switch self {
        case .time: TodayUsage.format(value)
        case .pickups: "\(Int(value)) 回"
        case .perPickup: perPickupText(value)
        case .notifications: "\(Int(value)) 件"
        }
    }

    func total(of usage: TodayUsage) -> String? {
        switch self {
        case .time: "合計 \(TodayUsage.format(usage.total))"
        case .pickups: "合計 \(usage.pickups) 回"
        case .perPickup: nil
        case .notifications: "合計 \(usage.notifications) 件"
        }
    }

    private func perPickupText(_ value: Double) -> String {
        guard value > 0 else {
            return "-"
        }

        let minutes = Int(value / 60)

        return minutes < 1 ? "1 回 1 分未満" : "1 回 \(minutes) 分"
    }
}

struct UsageFact: View {
    let value: String
    let note: String

    init(
        _ value: String,
        note: String
    ) {
        self.value = value
        self.note = note
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
        .frame(height: 64)
        .background(Palette.coralSoft, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    Palette.coral.opacity(0.4),
                    style: StrokeStyle(lineWidth: 2, dash: [4, 4])
                )
        }
    }
}

struct UsageSortButton: View {
    let value: String
    let note: String
    let sort: UsageSort
    let selection: UsageSort

    init(
        _ value: String,
        note: String,
        sort: UsageSort,
        selection: UsageSort
    ) {
        self.value = value
        self.note = note
        self.sort = sort
        self.selection = selection
    }

    var body: some View {
        label
            .background { face }
            .offset(y: isSelected ? 5 : 0)
            .background(alignment: .top) { thickness }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(note) \(value)")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension UsageSortButton {
    var isSelected: Bool {
        selection == sort
    }

    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16)
    }

    var label: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.heavy))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(note)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(isSelected ? Palette.card.opacity(0.85) : Palette.muted)

            if isSelected {
                Label("並べ中", systemImage: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Palette.card.opacity(0.85))
            }
        }
        .foregroundStyle(isSelected ? Palette.card : Palette.ink)
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
    }

    var face: some View {
        ZStack {
            if isSelected {
                shape.fill(
                    sort.deep.shadow(
                        .inner(color: Palette.ink.opacity(0.3), radius: 4, y: 3)
                    )
                )
            } else {
                shape.fill(sort.soft)

                shape.fill(
                    LinearGradient(
                        colors: [Palette.card.opacity(0.75), Palette.card.opacity(0)],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.55)
                    )
                )
            }

            shape.strokeBorder(sort.deep, lineWidth: 2)
        }
    }

    var thickness: some View {
        shape
            .fill(sort.deep)
            .shadow(
                color: Palette.ink.opacity(isSelected ? 0 : 0.22),
                radius: 8,
                y: 10
            )
            .offset(y: 6)
    }
}
