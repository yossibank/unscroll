import SwiftUI

public struct ProvisionalMark: View {
    public init() {}

    public var body: some View {
        Text("仮")
            .font(.caption2)
            .foregroundStyle(Palette.muted)
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, 4)
            .background(Palette.paper, in: Capsule())
    }
}
