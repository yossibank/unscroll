import DesignSystem
import SwiftUI

struct HourBars: View {
    let hours: [TimeInterval]

    private let barHeight: CGFloat = 84
    private let hourLength: Double = 60 * 60

    private let bands = [
        (hours: 5, color: Palette.plumSoft),
        (hours: 6, color: Palette.sunSoft),
        (hours: 7, color: Palette.skySoft),
        (hours: 6, color: Palette.plumSoft)
    ]

    var body: some View {
        let peak = hours.max() ?? 0
        let peakHour = peak > 0 ? hours.firstIndex(of: peak) : nil

        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(hours.indices, id: \.self) { hour in
                    bar(hour, isPeak: hour == peakHour)
                }
            }
            .frame(height: barHeight, alignment: .bottom)

            axis
        }
        .padding(.top, 32)
        .padding(.horizontal, Spacing.small)
        .padding(.bottom, Spacing.small)
        .background { background }
        .accessibilityHidden(true)
    }
}

private extension HourBars {
    var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 4,
            bottomLeadingRadius: 2,
            bottomTrailingRadius: 2,
            topTrailingRadius: 4
        )
    }

    var background: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                ForEach(bands.indices, id: \.self) { index in
                    Rectangle()
                        .fill(bands[index].color)
                        .frame(width: proxy.size.width * CGFloat(bands[index].hours) / 24)
                }
            }
        }
        .clipShape(.rect(cornerRadius: 16))
    }

    var axis: some View {
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
        .frame(height: 12)
    }

    @ViewBuilder
    func bar(
        _ hour: Int,
        isPeak: Bool
    ) -> some View {
        let ratio = min(hours[hour] / hourLength, 1)
        let tone = Palette.hour(hour)

        if ratio > 0 {
            shape
                .fill(
                    LinearGradient(
                        colors: [tone.opacity(0.6), tone],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: max(6, barHeight * ratio))
                .frame(maxWidth: .infinity)
                .overlay(alignment: .top) {
                    if isPeak {
                        bubble(Int(hours[hour] / 60))
                            .fixedSize()
                            .alignmentGuide(.top) { $0[.bottom] + 2 }
                    }
                }
        } else {
            shape
                .fill(Palette.ink.opacity(0.08))
                .frame(height: 3)
                .frame(maxWidth: .infinity)
        }
    }

    func bubble(_ minutes: Int) -> some View {
        VStack(spacing: 0) {
            Text("\(minutes) 分")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.card)
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, 4)
                .background(Palette.ink, in: Capsule())

            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 6))
                .foregroundStyle(Palette.ink)
        }
    }
}

struct UsageRest: View {
    let start: Int
    let length: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { proxy in
                Capsule()
                    .fill(Palette.leaf)
                    .frame(width: proxy.size.width * CGFloat(length) / 24)
                    .offset(x: proxy.size.width * CGFloat(start) / 24)
            }
            .frame(height: 8)
            .padding(.horizontal, Spacing.small)

            Text("\(start)〜\(start + length - 1) 時台、\(length) 時間スマホを置けました")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)
        }
    }
}
