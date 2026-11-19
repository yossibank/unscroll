import Core
import DesignSystem
import SwiftUI

struct SettingsStrictness: View {
    @Binding var strictness: Strictness

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack(spacing: Spacing.small) {
                ForEach(Strictness.allCases, id: \.self) { item in
                    stamp(item)
                }
            }

            shieldSample

            Text(example(for: strictness))
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .animation(.snappy, value: strictness)
    }
}

private extension SettingsStrictness {
    var shieldSample: some View {
        let secondaryInk = strictness == .strict ? Palette.muted : Palette.teal

        return VStack(spacing: Spacing.small) {
            Image(systemName: "envelope.open.fill")
                .font(.title3)
                .foregroundStyle(Palette.teal)

            Text("旅先からの手紙")
                .font(.footnote.weight(.heavy))
                .foregroundStyle(Palette.ink)

            Text("あと 32 km で浜名湖に着くんだ。")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)

            Text("旅に戻る")
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.card)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.small)
                .background(Palette.teal, in: Capsule())
                .padding(.top, 4)

            Text(secondaryButton(for: strictness))
                .font(.caption.weight(.heavy))
                .foregroundStyle(secondaryInk)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: 240)
        .background(Palette.paper, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Palette.paperDeep, lineWidth: 1.5)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("止めた画面の見え方")
        .accessibilityValue(detail(for: strictness))
    }

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
        case .gentle: "止めたアプリを 1 分だけ開けます"
        case .normal: "10 秒待つと開けます"
        case .strict: "旅が終わるまで開けません"
        }
    }

    func secondaryButton(for item: Strictness) -> String {
        switch item {
        case .gentle: "1 分だけ開く"
        case .normal: "10 秒待って開く"
        case .strict: "開くボタンは出ません"
        }
    }

    func example(for item: Strictness) -> String {
        switch item {
        case .gentle: "例：連絡を待つ日に。開いても 1 分で、また止まります。"
        case .normal: "例：つい SNS を開いてしまう時に。10 秒待つ間に、本当に要るか考えられます。"
        case .strict: "例：試験の前や寝る前に。旅が終わるまで、どうやっても開けません。"
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
