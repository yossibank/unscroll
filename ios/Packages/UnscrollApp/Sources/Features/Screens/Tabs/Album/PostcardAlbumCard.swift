import Core
import DesignSystem
import SwiftUI

struct PostcardAlbumCard: View {
    let entry: PostcardAlbumModel.Entry
    let index: Int

    var body: some View {
        if let arrival = entry.arrival {
            collected(arrival)
        } else {
            uncollected
        }
    }
}

private extension PostcardAlbumCard {
    static let tapes = [Palette.coral, Palette.teal, Palette.sun, Palette.sky]

    var tilt: Double {
        index.isMultiple(of: 2) ? -1.8 : 1.6
    }

    var remainingNote: String {
        guard entry.remainingKilometers > 0 else {
            return "旅が終わると届く"
        }

        return "あと \(entry.remainingKilometers.formatted()) km"
    }

    var uncollected: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            AirmailEnvelope(note: remainingNote)
                .rotationEffect(.degrees(tilt))

            Text(entry.landmark.name)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
        }
    }

    func collected(_ arrival: Arrival) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            PostcardArt(landmark: entry.landmark)
                .overlay(alignment: .topTrailing) {
                    if arrival.isDecorated {
                        Image(systemName: "house.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Palette.coral)
                            .frame(width: 24, height: 24)
                            .background(.white, in: .rect(cornerRadius: 4))
                            .padding(4)
                            .accessibilityLabel("部屋に飾っている")
                    }
                }

            Text(entry.landmark.name)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 4)

            Text("\(entry.landmark.kilometer.formatted()) km 地点")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityLabel(arrivedNote(arrival))
        }
        .padding(Spacing.small)
        .background(Palette.card, in: .rect(cornerRadius: 4))
        .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 4)
        .overlay(alignment: .bottomTrailing) {
            Postmark(date: arrival.arrivedAt)
                .offset(x: 4, y: -12)
        }
        .overlay(alignment: .top) {
            MaskingTape(tint: Self.tapes[index % Self.tapes.count], width: 56)
                .rotationEffect(.degrees(-tilt * 2))
                .offset(y: -10)
        }
        .rotationEffect(.degrees(tilt))
    }

    func arrivedNote(_ arrival: Arrival) -> String {
        let format = Date.VerbatimFormatStyle(
            format: "\(month: .defaultDigits)/\(day: .defaultDigits)",
            timeZone: .current,
            calendar: .current
        )
        let date = arrival.arrivedAt.formatted(format)

        return "\(entry.landmark.kilometer.formatted()) km 地点、\(date) に届いた"
    }
}

private struct AirmailEnvelope: View {
    let note: String

    var body: some View {
        Palette.paper
            .clipShape(.rect(cornerRadius: 2))
            .aspectRatio(LandmarkArt.aspectRatio * 0.9, contentMode: .fit)
            .overlay {
                content
            }
            .padding(6)
            .background {
                stripes
                    .clipShape(.rect(cornerRadius: 4))
            }
    }
}

private extension AirmailEnvelope {
    var content: some View {
        VStack(spacing: Spacing.small) {
            Text("?")
                .font(.title3.weight(.black))
                .foregroundStyle(Palette.floorEdge)
                .frame(width: 44, height: 52)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(
                            Palette.floorEdge,
                            style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                        )
                }

            Text(note)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(Palette.tealDeep)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
        }
    }

    var stripes: some View {
        Canvas { context, size in
            let colors = [Palette.coral, Color.white, Palette.sky, Color.white]
            let width: CGFloat = 8

            var x = -size.height
            var index = 0

            while x < size.width + size.height {
                var path = Path()

                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                path.addLine(to: CGPoint(x: x + size.height + width, y: 0))
                path.addLine(to: CGPoint(x: x + width, y: size.height))
                path.closeSubpath()

                context.fill(path, with: .color(colors[index % colors.count]))
                x += width
                index += 1
            }
        }
    }
}
