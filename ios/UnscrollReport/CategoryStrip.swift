import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct CategoryStrip: View {
    static let legendCount = 4

    let categories: [CategoryUsage]

    private let tints = [Palette.coral, Palette.sky, Palette.plum, Palette.sunDeep]

    var body: some View {
        let named = categories.filter { $0.name != CategoryUsage.otherName }
        let shown = Array(named.prefix(3))
        let shownNames = Set(shown.map(\.name))
        let rest = categories
            .filter { !shownNames.contains($0.name) }
            .reduce(0) { $0 + $1.duration }
        let other = rest > 0 ? [(CategoryUsage.otherName, rest)] : []
        let parts = shown.map { ($0.name, $0.duration) } + other
        let sum = max(parts.reduce(0) { $0 + $1.1 }, 1)

        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    ForEach(parts.indices, id: \.self) { index in
                        tints[index % tints.count]
                            .frame(width: max(4, (proxy.size.width - 6) * parts[index].1 / sum))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.paperDeep)
                .clipShape(Capsule())
            }
            .frame(height: 10)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(0..<Self.legendCount, id: \.self) { index in
                    if index < parts.count {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(tints[index % tints.count])
                                .frame(width: 8, height: 8)

                            Text(
                                "\(parts[index].0) \(Int((parts[index].1 / sum * 100).rounded()))%"
                            )
                            .font(.caption2.weight(.bold))
                        }
                    } else {
                        Text(index == 0 ? "まだ記録がありません" : " ")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Palette.muted)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
