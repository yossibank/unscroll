import Core
import SwiftUI

struct LaunchTraveler: View {
    let companion: Companion
    let pose: Companion.Pose
    let size: CGFloat
    let lift: CGFloat
    let holdsBag: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Ellipse()
                .fill(Palette.ink.opacity(0.2))
                .frame(width: size * 0.64, height: size * 0.14)
                .offset(x: size * 0.18, y: size * 0.88)

            if !holdsBag {
                TravelBag()
                    .frame(width: bagWidth, height: bagWidth * TravelBag.aspect)
                    .offset(x: -size * 0.24, y: size * 0.98 - bagWidth * TravelBag.aspect)
            }

            ZStack(alignment: .topLeading) {
                art
                    .stickerOutline(size: size)

                if holdsBag {
                    TravelBag()
                        .frame(width: bagWidth, height: bagWidth * TravelBag.aspect)
                        .rotationEffect(.degrees(-6), anchor: .top)
                        .offset(x: paw.x - bagWidth / 2, y: paw.y - unit * 1.2)

                    art
                        .mask(alignment: .topLeading) {
                            Rectangle()
                                .frame(width: unit * 4, height: unit * 4)
                                .offset(y: paw.y - unit * 2)
                        }
                }
            }
            .offset(y: -lift * size)
        }
        .frame(width: size, height: size, alignment: .topLeading)
    }
}

private extension LaunchTraveler {
    var art: some View {
        Image(companion.artName(pose), bundle: .module)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
    }
}

private extension LaunchTraveler {
    var unit: CGFloat {
        size / 32
    }

    var bagWidth: CGFloat {
        size * 0.3
    }

    var paw: CGPoint {
        let row: CGFloat = pose == .walk ? 20 : 17
        return CGPoint(x: unit * 1.5, y: unit * row)
    }
}

private struct TravelBag: View {
    static let aspect: CGFloat = 0.94

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = width * 0.7

            ZStack(alignment: .top) {
                BagHandle()
                    .stroke(
                        Color(hex: 0x7A4A2A),
                        style: StrokeStyle(lineWidth: width * 0.09, lineCap: .round)
                    )
                    .frame(width: width * 0.3, height: width * 0.32)

                ZStack {
                    RoundedRectangle(cornerRadius: width * 0.15)
                        .fill(Palette.coral)

                    HStack(spacing: width * 0.35) {
                        Rectangle()
                            .frame(width: width * 0.12)

                        Rectangle()
                            .frame(width: width * 0.12)
                    }
                    .foregroundStyle(Palette.coralDeep.opacity(0.55))

                    RoundedRectangle(cornerRadius: width * 0.05)
                        .fill(Palette.sunSoft)
                        .frame(width: width * 0.28, height: width * 0.2)

                    Circle()
                        .fill(Palette.sun)
                        .frame(width: width * 0.15, height: width * 0.15)
                        .offset(x: width * 0.35, y: -height * 0.28)
                }
                .clipShape(.rect(cornerRadius: width * 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: width * 0.15)
                        .strokeBorder(Palette.coralDeep, lineWidth: width * 0.05)
                )
                .frame(width: width, height: height)
                .offset(y: width * 0.24)
            }
            .frame(width: width, height: width * Self.aspect, alignment: .top)
            .stickerOutline(size: width * 0.8)
        }
    }
}

private struct BagHandle: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = rect.width * 0.3
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}
