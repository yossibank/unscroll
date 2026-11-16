import SwiftUI

public struct TagPill: View {
    let title: String
    let systemImage: String
    let tint: Color
    let wash: Color

    public init(
        _ title: String,
        systemImage: String,
        tint: Color,
        wash: Color
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.wash = wash
    }

    public var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.heavy))
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, Spacing.small + 4)
            .frame(minHeight: 28)
            .background(wash, in: Capsule())
    }
}

#Preview {
    HStack {
        TagPill(
            "東京 → 京都",
            systemImage: "map.fill",
            tint: Palette.tealDeep,
            wash: Palette.tealSoft
        )

        TagPill(
            "3 / 6 枚",
            systemImage: "envelope.fill",
            tint: Palette.coralDeep,
            wash: Palette.coralSoft
        )
    }
    .padding()
    .background(PaperBackdrop())
}
