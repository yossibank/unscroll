import Core
import DesignSystem
import SwiftUI

struct JourneyMapTag: View {
    let journey: Journey
    let nextLandmark: Landmark?
    let kilometersToNext: Int?

    var body: some View {
        HStack(spacing: Spacing.medium) {
            stamp

            VStack(alignment: .leading, spacing: 2) {
                if let landmark = nextLandmark, let remaining = kilometersToNext {
                    Text("次の名所")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Palette.sunDeep)
                        .tracking(2)

                    Text(landmark.name)
                        .journalTitleFont(size: 20)
                        .foregroundStyle(Palette.ink)

                    Text(note(remaining: remaining))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Palette.muted)
                } else {
                    Text("\(journey.landmarks.last?.name ?? "")に着きました")
                        .journalTitleFont(size: 20)
                        .foregroundStyle(Palette.ink)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.small + 4)
        .padding(.leading, Spacing.large + 12)
        .padding(.trailing, Spacing.medium)
        .background(Palette.sunSoft, in: TagShape())
        .overlay(alignment: .leading) {
            Circle()
                .fill(Palette.paper)
                .strokeBorder(Palette.sunDeep, lineWidth: 2)
                .frame(width: 12, height: 12)
                .padding(.leading, Spacing.medium)
        }
        .shadow(color: Palette.shadow, radius: 12, y: 8)
        .accessibilityElement(children: .combine)
    }
}

private extension JourneyMapTag {
    @ViewBuilder
    var stamp: some View {
        if nextLandmark == nil, let last = journey.landmarks.last {
            LandmarkArt(landmark: last)
                .frame(width: 64)
                .padding(4)
                .background(.white)
                .rotationEffect(.degrees(4))
        } else if let landmark = nextLandmark {
            LandmarkArt(landmark: landmark)
                .grayscale(1)
                .opacity(0.35)
                .frame(width: 64)
                .padding(4)
                .background(.white)
                .rotationEffect(.degrees(4))
                .accessibilityHidden(true)
        }
    }

    func note(remaining: Int) -> String {
        let minutes = remaining / Trip.kilometersPerMinute
        return "あと \(remaining.formatted()) km ・ 約 \(minutes) 分の旅で届く"
    }
}

private struct TagShape: Shape {
    func path(in rect: CGRect) -> Path {
        let point: CGFloat = 20
        let radius: CGFloat = 12

        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + point, y: rect.minY))
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
            tangent2End: CGPoint(x: rect.maxX, y: rect.maxY),
            radius: radius
        )
        path.addArc(
            tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
            tangent2End: CGPoint(x: rect.minX, y: rect.maxY),
            radius: radius
        )
        path.addLine(to: CGPoint(x: rect.minX + point, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}
