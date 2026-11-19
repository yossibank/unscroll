import SwiftUI

public struct FinishStamp: View {
    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Palette.coralDeep, lineWidth: 2)

            Circle()
                .strokeBorder(Palette.coralDeep, lineWidth: 1)
                .padding(4)

            VStack(spacing: 0) {
                Text("歩き")
                Text("きった")
            }
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(Palette.coralDeep)
        }
        .frame(width: 56, height: 56)
        .background(Palette.card.opacity(0.85), in: Circle())
        .rotationEffect(.degrees(-12))
        .accessibilityLabel("歩ききった")
    }
}

#Preview {
    FinishStamp()
        .padding(40)
        .background(PaperBackdrop())
}
