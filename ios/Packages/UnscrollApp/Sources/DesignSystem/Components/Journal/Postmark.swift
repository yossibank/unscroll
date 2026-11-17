import SwiftUI

public struct Postmark: View {
    private let date: Date

    public init(date: Date) {
        self.date = date
    }

    public var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Palette.coralDeep, lineWidth: 2)

            VStack(spacing: 0) {
                Text(monthDay)
                    .font(.system(size: 13, weight: .black, design: .rounded))

                Text("着")
                    .font(.system(size: 8, weight: .heavy))
            }
            .foregroundStyle(Palette.coralDeep)
        }
        .frame(width: 56, height: 56)
        .background(alignment: .leading) {
            VStack(spacing: 10) {
                wave
                wave
            }
            .offset(x: -28)
        }
        .opacity(0.8)
        .rotationEffect(.degrees(-14))
        .accessibilityHidden(true)
    }
}

private extension Postmark {
    var monthDay: String {
        let format = Date.VerbatimFormatStyle(
            format: "\(month: .twoDigits).\(day: .twoDigits)",
            timeZone: .current,
            calendar: .current
        )

        return date.formatted(format)
    }

    var wave: some View {
        Rectangle()
            .stroke(Palette.coralDeep, style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
            .frame(width: 36, height: 0.5)
    }
}

#Preview {
    Postmark(date: .now)
        .padding(40)
        .background(PaperBackdrop())
}
