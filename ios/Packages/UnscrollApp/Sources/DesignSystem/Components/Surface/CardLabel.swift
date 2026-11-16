import SwiftUI

public struct CardLabel<Trailing: View>: View {
    let title: String
    let systemImage: String
    let tint: Color
    let wash: Color
    let trailing: Trailing

    public init(
        _ title: String,
        systemImage: String,
        tint: Color,
        wash: Color,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.wash = wash
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 24, height: 24)
                .background(wash, in: .rect(cornerRadius: 8))

            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.muted)

            Spacer(minLength: 4)

            trailing
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

public extension CardLabel where Trailing == EmptyView {
    init(
        _ title: String,
        systemImage: String,
        tint: Color,
        wash: Color
    ) {
        self.init(
            title,
            systemImage: systemImage,
            tint: tint,
            wash: wash
        ) {
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        CardLabel(
            "進んだ距離",
            systemImage: "figure.walk",
            tint: Palette.teal,
            wash: Palette.tealSoft
        ) {
            Text("あと 80 km で名古屋城")
                .foregroundStyle(Palette.teal)
        }

        CardLabel(
            "旅の長さ",
            systemImage: "timer",
            tint: Palette.coral,
            wash: Palette.coralSoft
        )
    }
    .roundedCard()
    .padding()
    .background(PaperBackdrop())
}
