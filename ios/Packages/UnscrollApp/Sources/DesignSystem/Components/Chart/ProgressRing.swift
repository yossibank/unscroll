import SwiftUI

public struct ProgressRing: View {
    let ratio: Double
    let label: String
    let tint: Color
    let wash: Color

    public init(
        ratio: Double,
        label: String,
        tint: Color,
        wash: Color
    ) {
        self.ratio = ratio
        self.label = label
        self.tint = tint
        self.wash = wash
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(wash, lineWidth: 6)

            Circle()
                .trim(from: 0, to: clamped)
                .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(label)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(8)
        }
        .frame(width: 56, height: 56)
    }
}

private extension ProgressRing {
    var clamped: Double {
        min(max(ratio, 0), 1)
    }
}

#Preview {
    HStack {
        ProgressRing(
            ratio: 0.54,
            label: "54%",
            tint: Palette.teal,
            wash: Palette.tealSoft
        )

        ProgressRing(
            ratio: 0.5,
            label: "3/6",
            tint: Palette.coral,
            wash: Palette.coralSoft
        )
    }
    .padding()
}
