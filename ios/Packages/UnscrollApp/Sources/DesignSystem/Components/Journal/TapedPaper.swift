import SwiftUI

public struct TapedPaper<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .clipShape(.rect(cornerRadius: 4))
            .padding(Spacing.small)
            .background(Palette.card, in: .rect(cornerRadius: 6))
            .shadow(color: Palette.ink.opacity(0.14), radius: 8, y: 6)
            .overlay(alignment: .topLeading) {
                MaskingTape(tint: Palette.coral)
                    .rotationEffect(.degrees(-6))
                    .offset(x: Spacing.large, y: -10)
            }
            .overlay(alignment: .bottomTrailing) {
                MaskingTape(tint: Palette.sky)
                    .rotationEffect(.degrees(-4))
                    .offset(x: -Spacing.large, y: 10)
            }
            .rotationEffect(.degrees(-1))
    }
}

#Preview {
    TapedPaper {
        Rectangle()
            .fill(Palette.leaf)
            .aspectRatio(16 / 10, contentMode: .fit)
    }
    .padding(Spacing.large)
    .background(PaperBackdrop())
}
