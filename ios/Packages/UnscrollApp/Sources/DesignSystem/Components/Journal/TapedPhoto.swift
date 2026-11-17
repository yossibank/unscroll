import SwiftUI

public struct TapedPhoto<Content: View>: View {
    private let caption: String
    private let tilt: Double
    private let content: Content

    public init(
        caption: String,
        tilt: Double = 1,
        @ViewBuilder content: () -> Content
    ) {
        self.caption = caption
        self.tilt = tilt
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            content
                .clipShape(.rect(cornerRadius: 2))

            Text(caption)
                .handwritingFont(size: 15)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
        }
        .padding(Spacing.small)
        .background(Palette.card, in: .rect(cornerRadius: 4))
        .shadow(color: Palette.ink.opacity(0.14), radius: 8, y: 6)
        .overlay(alignment: .topLeading) {
            MaskingTape(tint: Palette.sun)
                .rotationEffect(.degrees(-36))
                .offset(x: -16, y: 0)
        }
        .overlay(alignment: .topTrailing) {
            MaskingTape(tint: Palette.teal)
                .rotationEffect(.degrees(36))
                .offset(x: 16, y: 0)
        }
        .rotationEffect(.degrees(tilt))
        .padding(.vertical, Spacing.small)
    }
}

#Preview {
    TapedPhoto(caption: "11/17　こむぎと部屋で") {
        Rectangle()
            .fill(Palette.sky)
            .aspectRatio(4 / 3, contentMode: .fit)
    }
    .padding(Spacing.large)
    .background(PaperBackdrop())
}
