import Core
import DesignSystem
import SwiftUI

struct SettingsStrictness: View {
    @Binding var strictness: Strictness

    var body: some View {
        HStack(spacing: Spacing.small) {
            ForEach(Strictness.allCases, id: \.self) { item in
                stamp(item)
            }
        }
    }
}

private extension SettingsStrictness {
    func stamp(_ item: Strictness) -> some View {
        let isSelected = strictness == item
        let border = isSelected ? Palette.sun : Palette.paperDeep
        let fill = isSelected ? Palette.sunSoft : Palette.card
        let traits: AccessibilityTraits = isSelected ? .isSelected : []

        return Button {
            strictness = item
        } label: {
            VStack(spacing: 4) {
                Text(mark(for: item))
                    .font(.caption.weight(.black))
                    .foregroundStyle(ink(for: item))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Circle()
                            .strokeBorder(ink(for: item), lineWidth: 2)
                    }
                    .rotationEffect(.degrees(-8))
                    .padding(.bottom, 4)

                Text(title(for: item))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(note(for: item))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, Spacing.small + 4)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(fill, in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(border, lineWidth: 2)
            }
            .animation(.snappy, value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title(for: item))
        .accessibilityValue(detail(for: item))
        .accessibilityAddTraits(traits)
    }
}

private extension SettingsStrictness {
    func mark(for item: Strictness) -> String {
        switch item {
        case .gentle: "1分"
        case .normal: "10秒"
        case .strict: "✕"
        }
    }

    func title(for item: Strictness) -> String {
        switch item {
        case .gentle: "やさしい"
        case .normal: "ふつう"
        case .strict: "きびしい"
        }
    }

    func note(for item: Strictness) -> String {
        switch item {
        case .gentle: "1 分だけ開ける"
        case .normal: "10 秒待つ"
        case .strict: "終わるまで"
        }
    }

    func detail(for item: Strictness) -> String {
        switch item {
        case .gentle: "止めたアプリを 1 分だけ開ける"
        case .normal: "10 秒待つと開ける"
        case .strict: "旅が終わるまで開けない"
        }
    }

    func ink(for item: Strictness) -> Color {
        switch item {
        case .gentle: Palette.leaf
        case .normal: Palette.sunDeep
        case .strict: Palette.plumDeep
        }
    }
}

#Preview {
    @Previewable @State var strictness = Strictness.normal

    SettingsStrictness(strictness: $strictness)
        .padding()
        .background(PaperBackdrop())
}
