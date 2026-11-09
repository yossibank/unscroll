import Core
import DesignSystem
import SwiftUI

/// 名所の絵はがきの絵。名所の絵を描くまでは、記号と仮の印で代える。
struct PostcardArt: View {
    let landmark: Landmark
    var symbolFont: Font = .largeTitle
    var showsProvisionalMark = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Palette.teal.opacity(0.25), Palette.coral.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    Image(systemName: symbol)
                        .font(symbolFont)
                        .foregroundStyle(Palette.ink.opacity(0.7))
                }

            if showsProvisionalMark {
                ProvisionalMark()
                    .padding(4)
            }
        }
        .aspectRatio(4 / 3, contentMode: .fit)
    }
}

private extension PostcardArt {
    var symbol: String {
        switch landmark.name {
        case "芦ノ湖":
            "mountain.2"
        case "三保の松原":
            "tree"
        case "浜名湖":
            "fish"
        case "名古屋城":
            "building.columns"
        case "琵琶湖":
            "sailboat"
        case "清水寺":
            "leaf"
        default:
            "photo"
        }
    }
}
