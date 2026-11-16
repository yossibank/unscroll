import SwiftUI

public extension View {
    func roundedCard(
        padding: CGFloat = 16,
        fill: some ShapeStyle = Palette.card
    ) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(fill, in: .rect(cornerRadius: RoundedCard.radius))
            .shadow(color: Palette.shadow, radius: 12, y: 8)
    }
}

public enum RoundedCard {
    public static let radius: CGFloat = 24
}

#Preview {
    VStack(spacing: 12) {
        Text("進んだ距離")
            .roundedCard()

        Text("次の名所")
            .roundedCard(fill: LinearGradient(
                colors: [Palette.sunSoft, Palette.card],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
    }
    .padding()
    .background(PaperBackdrop())
}
