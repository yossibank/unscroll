import DesignSystem
import SwiftUI

struct OnboardingUsageSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("今日のスマホ")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.skyDeep)
                .tracking(2)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.small) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("2")
                        .journalTitleFont(size: 28)

                    Text("時間")
                        .font(.caption.weight(.heavy))

                    Text("14")
                        .journalTitleFont(size: 28)

                    Text("分")
                        .font(.caption.weight(.heavy))
                }
                .foregroundStyle(Palette.ink)

                Label("昨日より 20 分少ない", systemImage: "arrow.down")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Palette.tealDeep)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, Spacing.small)
                    .padding(.vertical, 4)
                    .background(Palette.tealSoft, in: Capsule())
            }

            bars

            Text("21 時台に一番使った（52 分）")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.coralDeep)

            VStack(spacing: 0) {
                ForEach(Self.apps, id: \.name) { app in
                    appRow(app)
                }
            }
        }
        .padding(Spacing.medium)
        .background(Palette.card, in: .rect(cornerRadius: 6))
        .shadow(color: Palette.ink.opacity(0.14), radius: 8, y: 6)
        .overlay(alignment: .top) {
            MaskingTape(tint: Palette.sky)
                .rotationEffect(.degrees(-3))
                .offset(y: -10)
        }
        .rotationEffect(.degrees(1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("今日のスマホの見本。合計 2 時間 14 分、21 時台に一番使った")
    }
}

private extension OnboardingUsageSample {
    struct App {
        let name: String
        let minutes: Int
        let tint: Color
    }

    static let barHeight: CGFloat = 48

    static let minutes: [Double] = [
        2, 1, 0, 0, 0, 0, 10, 20, 13, 7, 5, 24,
        31, 10, 6, 8, 12, 17, 28, 37, 46, 52, 35, 15
    ]

    static let apps = [
        App(name: "動画", minutes: 58, tint: Palette.coral),
        App(name: "SNS", minutes: 42, tint: Palette.plum),
        App(name: "ゲーム", minutes: 21, tint: Palette.sun)
    ]

    var bars: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Self.minutes.indices, id: \.self) { hour in
                    let ratio = Self.minutes[hour] / 60

                    UnevenRoundedRectangle(topLeadingRadius: 3, topTrailingRadius: 3)
                        .fill(ratio > 0 ? Palette.hour(hour) : Palette.paperDeep)
                        .frame(height: max(3, Self.barHeight * ratio))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: Self.barHeight, alignment: .bottom)

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
        .padding(.vertical, 4)
    }

    func appRow(_ app: App) -> some View {
        let ratio = Double(app.minutes) / 60

        return HStack(spacing: Spacing.small + 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(app.tint)
                .frame(width: 24, height: 24)

            Text(app.name)
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .frame(width: 48, alignment: .leading)

            Capsule()
                .fill(Palette.paperDeep)
                .frame(height: 6)
                .overlay(alignment: .leading) {
                    GeometryReader { proxy in
                        Capsule()
                            .fill(app.tint)
                            .frame(width: proxy.size.width * ratio)
                    }
                }

            Text("\(app.minutes) 分")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .monospacedDigit()
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Palette.paperDeep)
                .frame(height: 1)
        }
    }
}
