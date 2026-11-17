import DesignSystem
import SwiftUI

struct PostcardStampRally: View {
    let entries: [PostcardAlbumModel.Entry]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small + 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("スタンプラリー")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.muted)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(collectedCount)")
                        .journalTitleFont(size: 24)
                        .foregroundStyle(Palette.coralDeep)

                    Text("/ \(entries.count)")
                        .font(.footnote.weight(.heavy))
                        .foregroundStyle(Palette.muted)
                }
            }

            HStack(spacing: Spacing.small) {
                ForEach(Array(entries.enumerated()), id: \.element.landmark.name) { index, entry in
                    stamp(entry, index: index)
                }
            }
            .accessibilityHidden(true)
        }
        .roundedCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("あつめた絵はがき \(collectedCount) / \(entries.count) 枚")
    }
}

private extension PostcardStampRally {
    var collectedCount: Int {
        entries.count(where: \.isCollected)
    }

    @ViewBuilder
    func stamp(
        _ entry: PostcardAlbumModel.Entry,
        index: Int
    ) -> some View {
        let label = String(entry.landmark.name.prefix(2))

        if entry.isCollected {
            Text(label)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Palette.coralDeep)
                .frame(width: 36, height: 36)
                .background(Palette.coralSoft, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(Palette.coral, lineWidth: 2.5)
                }
                .rotationEffect(.degrees(index.isMultiple(of: 2) ? -10 : 8))
        } else {
            Text(label)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Palette.floorEdge)
                .frame(width: 36, height: 36)
                .overlay {
                    Circle()
                        .strokeBorder(
                            Palette.floorEdge.opacity(0.7),
                            style: StrokeStyle(lineWidth: 2, dash: [4, 3])
                        )
                }
        }
    }
}
