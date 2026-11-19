import Core
import DesignSystem
import SwiftUI

struct PostcardAlbumCovers: View {
    let covers: [PostcardAlbumModel.Cover]
    let shownID: String
    let onSelect: (String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: Spacing.medium) {
                    ForEach(Array(covers.enumerated()), id: \.element.id) { index, cover in
                        coverButton(cover, index: index)
                            .id(cover.id)
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.medium)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                proxy.scrollTo(shownID, anchor: .center)
            }
        }
    }
}

private extension PostcardAlbumCovers {
    static let tapes = [Palette.coral, Palette.teal, Palette.sun, Palette.sky, Palette.plum]

    func coverButton(
        _ cover: PostcardAlbumModel.Cover,
        index: Int
    ) -> some View {
        let isShown = cover.id == shownID
        let tilt = isShown ? 0 : (index.isMultiple(of: 2) ? -2.0 : 1.8)
        let scale = isShown ? 1.04 : 1
        let lift = isShown ? -4.0 : 0
        let tape = Self.tapes[index % Self.tapes.count]
        let traits: AccessibilityTraits = isShown ? .isSelected : []

        return Button {
            onSelect(cover.id)
        } label: {
            coverFace(cover, isShown: isShown)
                .rotationEffect(.degrees(tilt))
                .scaleEffect(scale)
                .offset(y: lift)
                .animation(.snappy, value: isShown)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(cover.journey.name)
        .accessibilityValue(countText(cover))
        .accessibilityAddTraits(traits)
        .overlay(alignment: .top) {
            if isShown {
                MaskingTape(tint: tape, width: 48)
                    .offset(y: -8)
            }
        }
    }

    func coverFace(
        _ cover: PostcardAlbumModel.Cover,
        isShown: Bool
    ) -> some View {
        let border = isShown ? Palette.teal : Palette.paperDeep
        let borderWidth = isShown ? 2.0 : 1
        let shadow = isShown ? 10.0 : 4

        return VStack(alignment: .leading, spacing: 4) {
            art(cover)

            Text(cover.journey.name)
                .font(.caption.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 4)

            badge(cover)
        }
        .padding(Spacing.small)
        .frame(width: 128)
        .background(Palette.card, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(border, lineWidth: borderWidth)
        }
        .shadow(color: Palette.ink.opacity(0.14), radius: shadow, y: 4)
    }

    @ViewBuilder
    func art(_ cover: PostcardAlbumModel.Cover) -> some View {
        let saturation = cover.isStarted ? 1.0 : 0
        let opacity = cover.isStarted ? 1.0 : 0.55

        if let landmark = cover.art {
            LandmarkArt(landmark: landmark)
                .clipShape(.rect(cornerRadius: 4))
                .saturation(saturation)
                .opacity(opacity)
        }
    }

    @ViewBuilder
    func badge(_ cover: PostcardAlbumModel.Cover) -> some View {
        let symbol = cover.isCurrent ? "figure.walk" : "envelope.fill"
        let tint = cover.isCurrent ? Palette.tealDeep : Palette.coralDeep

        if cover.isStarted {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 9, weight: .black))

                Text(countText(cover))
                    .font(.caption2.weight(.heavy))
                    .monospacedDigit()
            }
            .foregroundStyle(tint)
        } else {
            Text("まだ")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.muted)
        }
    }
}

private extension PostcardAlbumCovers {
    func countText(_ cover: PostcardAlbumModel.Cover) -> String {
        "\(cover.collectedCount) / \(cover.totalCount) 枚"
    }
}
