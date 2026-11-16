import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct TodayUsageView: View {
    let usage: TodayUsage

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            total

            hourBars

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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension TodayUsageView {
    static let appTints = [Palette.coral, Palette.sky, Palette.plum]

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
        let peak = max(usage.hours.max() ?? 0, 60)

        return VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(usage.hours.indices, id: \.self) { hour in
                    let ratio = usage.hours[hour] / peak

                    UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                        .fill(ratio > 0 ? tint(forHour: hour) : Palette.paperDeep)
                        .frame(height: max(3, 48 * ratio))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 48, alignment: .bottom)

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
            return "この時間を旅にすると \(kilometers) km 進めたよ"
        }

        return "この時間を旅にすると \(kilometers) km。\(reached.name)まで行けたよ"
    }

    func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }
}
