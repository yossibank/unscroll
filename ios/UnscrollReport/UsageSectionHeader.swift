import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

struct UsageSectionHeader: View {
    let title: String
    let trailing: String?

    init(
        _ title: String,
        trailing: String? = nil
    ) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: Spacing.small) {
            Text(title)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            if let trailing {
                Text(trailing)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .font(.caption.weight(.bold))
    }
}
