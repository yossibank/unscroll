import DesignSystem
import SwiftUI

struct UsageSortButton: View {
    @Binding var selection: UsageSort

    let value: String
    let note: String
    let sort: UsageSort

    init(
        _ value: String,
        note: String,
        sort: UsageSort,
        selection: Binding<UsageSort>
    ) {
        self.value = value
        self.note = note
        self.sort = sort
        _selection = selection
    }

    var body: some View {
        Button {
            selection = isSelected ? .time : sort
        } label: {
            label
                .background { face }
                .offset(y: isSelected ? 5 : 0)
        }
        .buttonStyle(.plain)
        .background(alignment: .top) { thickness }
        .animation(.spring(duration: 0.25, bounce: 0.3), value: isSelected)
        .accessibilityLabel("\(note) \(value)")
        .accessibilityHint(sort.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension UsageSortButton {
    var isSelected: Bool {
        selection == sort
    }

    var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16)
    }

    var label: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.heavy))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(note)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(isSelected ? Palette.card.opacity(0.85) : Palette.muted)

            Label(
                isSelected ? "並べ中" : "並べる",
                systemImage: isSelected ? "checkmark" : "arrow.up.arrow.down"
            )
            .font(.system(size: 9, weight: .heavy))
            .foregroundStyle(isSelected ? Palette.card.opacity(0.85) : sort.deep)
        }
        .foregroundStyle(isSelected ? Palette.card : Palette.ink)
        .padding(Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 64)
    }

    var face: some View {
        ZStack {
            if isSelected {
                shape.fill(
                    sort.deep.shadow(
                        .inner(color: Palette.ink.opacity(0.3), radius: 4, y: 3)
                    )
                )
            } else {
                shape.fill(sort.soft)

                shape.fill(
                    LinearGradient(
                        colors: [Palette.card.opacity(0.75), Palette.card.opacity(0)],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.55)
                    )
                )
            }

            shape.strokeBorder(sort.deep, lineWidth: 2)
        }
    }

    var thickness: some View {
        shape
            .fill(sort.deep)
            .shadow(
                color: Palette.ink.opacity(isSelected ? 0 : 0.22),
                radius: 8,
                y: 10
            )
            .offset(y: 6)
    }
}
