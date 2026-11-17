import SwiftUI

public struct TicketGauge: View {
    private let ratio: Double

    public init(ratio: Double) {
        self.ratio = ratio
    }

    public var body: some View {
        Capsule()
            .fill(Palette.tealSoft)
            .frame(height: 8)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(Palette.teal)
                        .frame(width: proxy.size.width * min(max(ratio, 0), 1))
                }
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    TicketGauge(ratio: 0.38)
        .padding()
        .background(PaperBackdrop())
}
