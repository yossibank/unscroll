import DesignSystem
import SwiftUI

struct UsageRest: View {
    let rest: (start: Int, length: Int)?

    var body: some View {
        let start = rest?.start ?? 0
        let length = rest?.length ?? 0

        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { proxy in
                Capsule()
                    .fill(Palette.leaf)
                    .frame(width: proxy.size.width * CGFloat(length) / 24)
                    .offset(x: proxy.size.width * CGFloat(start) / 24)
            }
            .frame(height: 8)
            .padding(.horizontal, Spacing.small)

            Text(note)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

private extension UsageRest {
    var note: String {
        guard let rest else {
            return "スマホを置けた時間は、まだありません"
        }

        return "\(rest.start)〜\(rest.start + rest.length - 1) 時台、\(rest.length) 時間スマホを置けました"
    }
}
