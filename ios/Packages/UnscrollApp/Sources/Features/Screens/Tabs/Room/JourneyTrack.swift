import DesignSystem
import SwiftUI

struct JourneyTrack: View {
    let ratio: Double

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(ratio, 0), 1)
            let filled = proxy.size.width * clamped

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Palette.tealSoft)
                    .frame(height: 12)

                Capsule()
                    .fill(LinearGradient(
                        colors: [Palette.teal, Palette.leaf],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: max(12, filled), height: 12)

                Circle()
                    .fill(.white)
                    .overlay {
                        Circle()
                            .strokeBorder(Palette.teal, lineWidth: 3)
                    }
                    .frame(width: 22, height: 22)
                    .shadow(color: Palette.teal.opacity(0.3), radius: 4, y: 2)
                    .offset(x: min(max(0, filled - 11), proxy.size.width - 22))
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 22)
        .accessibilityHidden(true)
    }
}

#Preview {
    JourneyTrack(ratio: 0.54)
        .padding()
}
