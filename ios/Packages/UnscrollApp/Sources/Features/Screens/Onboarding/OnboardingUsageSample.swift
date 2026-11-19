import DesignSystem
import SwiftUI

struct OnboardingUsageSample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("今日のスマホ")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.skyDeep)
                .tracking(2)

            total

            Label("昨日の同じ時刻より 20 分少ないです", systemImage: "arrow.down")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.tealDeep)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Spacing.small)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
                .background(Palette.tealDeep.opacity(0.12), in: .rect(cornerRadius: 8))

            HStack(spacing: 6) {
                fact("48 回", note: "手に取った", ink: Palette.sunDeep, wash: Palette.sunSoft)

                fact("3 分", note: "1 回あたり", ink: Palette.skyDeep, wash: Palette.skySoft)

                fact("86 件", note: "通知", ink: Palette.plumDeep, wash: Palette.plumSoft)

                firstPickup
            }
            .padding(.bottom, 4)

            HStack {
                Text("1 日の流れ")
                    .foregroundStyle(Palette.muted)

                Spacer(minLength: 0)

                Text("21 時台がいちばん（52 分）")
                    .foregroundStyle(Palette.ink)
            }
            .font(.system(size: 10, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            bars

            VStack(spacing: 6) {
                ForEach(Self.apps, id: \.name) { app in
                    appRow(app)
                }
            }
            .padding(.top, 4)
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
        .accessibilityLabel("今日のスマホの見本。合計 2 時間 14 分、21 時台がいちばん使った時間です")
    }
}

private extension OnboardingUsageSample {
    struct App {
        let name: String
        let minutes: Int
        let tint: Color
    }

    static let barHeight: CGFloat = 28
    static let peakHour = 21

    static let minutes: [Double] = [
        2, 1, 0, 0, 0, 0, 10, 20, 13, 7, 5, 24,
        31, 10, 6, 8, 12, 17, 28, 37, 46, 52, 35, 15
    ]

    static let bands: [(hours: Int, color: Color)] = [
        (5, Palette.plumSoft),
        (6, Palette.sunSoft),
        (7, Palette.skySoft),
        (6, Palette.plumSoft)
    ]

    static let apps = [
        App(name: "動画", minutes: 58, tint: Palette.coral),
        App(name: "SNS", minutes: 42, tint: Palette.sky)
    ]

    var total: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text("2")
                .font(.system(size: 28, weight: .heavy))

            Text("時間")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .padding(.trailing, 4)

            Text("14")
                .font(.system(size: 28, weight: .heavy))

            Text("分")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.muted)
        }
        .foregroundStyle(Palette.ink)
        .monospacedDigit()
    }

    var bars: some View {
        VStack(spacing: 2) {
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Self.minutes.indices, id: \.self) { hour in
                    bar(hour)
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
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(Palette.muted)
        }
        .padding(.top, 20)
        .padding(.horizontal, 6)
        .padding(.bottom, 4)
        .background {
            GeometryReader { proxy in
                HStack(spacing: 0) {
                    ForEach(Self.bands.indices, id: \.self) { index in
                        Rectangle()
                            .fill(Self.bands[index].color)
                            .frame(width: proxy.size.width * CGFloat(Self.bands[index].hours) / 24)
                    }
                }
            }
            .clipShape(.rect(cornerRadius: 12))
        }
    }

    var bubble: some View {
        VStack(spacing: 0) {
            Text("52 分")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(Palette.card)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Palette.ink, in: Capsule())

            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 5))
                .foregroundStyle(Palette.ink)
        }
    }

    var firstPickup: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("6:42")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .monospacedDigit()

            Text("最初に見た")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Palette.muted)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background(Palette.coralSoft, in: .rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    Palette.coral.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
                )
        }
    }

    func bar(_ hour: Int) -> some View {
        let ratio = Self.minutes[hour] / 60
        let fill = ratio > 0 ? Palette.hour(hour) : Palette.paperDeep

        return UnevenRoundedRectangle(topLeadingRadius: 2, topTrailingRadius: 2)
            .fill(fill)
            .frame(height: max(2, Self.barHeight * ratio))
            .frame(maxWidth: .infinity)
            .overlay(alignment: .top) {
                if hour == Self.peakHour {
                    bubble
                        .fixedSize()
                        .frame(height: 0, alignment: .bottom)
                        .offset(y: -2)
                }
            }
    }

    func fact(
        _ value: String,
        note: String,
        ink: Color,
        wash: Color
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: 10)

        return VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .monospacedDigit()

            Text(note)
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(Palette.muted)

            Label("並べる", systemImage: "arrow.up.arrow.down")
                .font(.system(size: 7, weight: .heavy))
                .foregroundStyle(ink)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 44)
        .background {
            ZStack {
                shape.fill(wash)

                shape.fill(
                    LinearGradient(
                        colors: [Palette.card.opacity(0.75), Palette.card.opacity(0)],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.55)
                    )
                )

                shape.strokeBorder(ink, lineWidth: 1.5)
            }
        }
        .background(alignment: .top) {
            shape
                .fill(ink)
                .shadow(color: Palette.ink.opacity(0.22), radius: 5, y: 6)
                .offset(y: 4)
        }
    }

    func appRow(_ app: App) -> some View {
        let ratio = Double(app.minutes) / 58

        return HStack(spacing: Spacing.small) {
            RoundedRectangle(cornerRadius: 5)
                .fill(app.tint)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(app.name)
                        .foregroundStyle(Palette.ink)

                    Spacer(minLength: 0)

                    Text("\(app.minutes) 分")
                        .foregroundStyle(Palette.muted)
                        .monospacedDigit()
                }
                .font(.system(size: 10, weight: .bold))

                Capsule()
                    .fill(Palette.paperDeep)
                    .frame(height: 5)
                    .overlay(alignment: .leading) {
                        GeometryReader { proxy in
                            Capsule()
                                .fill(app.tint)
                                .frame(width: proxy.size.width * ratio)
                        }
                    }
            }
        }
    }
}
