import CoreText
import DesignSystem
import SwiftUI
import Testing
import UIKit

@MainActor
struct SnapshotTests {
    @Test
    func render() throws {
        Self.registerFonts()

        for (index, page) in Self.pages.enumerated() {
            let shots = try page.art.raws.map(Self.image)
            let view = StorePage(
                page: page,
                shots: shots,
                index: index
            )

            try Self.write(view, to: page.name)
        }
    }
}

extension SnapshotTests {
    struct Page {
        let name: String
        let lines: [String]
        let lead: Lead
        let art: Art
    }

    enum Lead {
        case adFree
        case note(String)
    }

    enum Art {
        case phone(String, angle: Double)
        case fan(left: String, center: String, right: String)

        var raws: [String] {
            switch self {
            case let .phone(raw, _): [raw]
            case let .fan(left, center, right): [left, center, right]
            }
        }
    }
}

private extension SnapshotTests {
    static let directory = "__OUT__"
    static let size = CGSize(width: 440, height: 956)

    static let pages = [
        Page(
            name: "01-room",
            lines: ["スマホを置くと、", "相棒が*旅に出る*"],
            lead: .adFree,
            art: .phone("01-room", angle: -4)
        ),
        Page(
            name: "02-trip",
            lines: ["旅の間は、", "*アプリ*もお留守番"],
            lead: .note("SNS も動画もゲームも、選んだアプリを止めます"),
            art: .phone("02-trip", angle: 0)
        ),
        Page(
            name: "03-result",
            lines: ["戻ってきたら、", "*絵はがき*が届く"],
            lead: .note("名所に着くと、ご当地の 1 枚とおみやげ"),
            art: .phone("03-result", angle: 3)
        ),
        Page(
            name: "04-map",
            lines: ["次は", "*どこへ行く？*"],
            lead: .note("名所めぐりから街道の旅まで、道のりを選べます"),
            art: .phone("04-map", angle: -3)
        ),
        Page(
            name: "05-album",
            lines: ["集めた分だけ、", "部屋が*にぎやか*に"],
            lead: .note("絵はがきとおみやげを、部屋に飾れます"),
            art: .fan(left: "03-result", center: "05-album", right: "01-room")
        )
    ]

    static var repository: URL {
        var url = URL(fileURLWithPath: directory)

        while url.path() != "/" {
            if FileManager.default
                .fileExists(atPath: url.appending(path: "store/screenshots/raw").path()) {
                return url
            }

            url.deleteLastPathComponent()
        }

        return url
    }

    static func registerFonts() {
        let fonts = repository.appending(path: "ios/Unscroll/Fonts")

        for name in ["ZenMaruGothic-Bold", "KleeOne-SemiBold"] {
            let url = fonts.appending(path: "\(name).ttf")
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func image(_ name: String) throws -> UIImage {
        let path = repository.appending(path: "store/screenshots/raw/\(name).png").path()
        return try #require(UIImage(contentsOfFile: path))
    }

    static func write(
        _ view: some View,
        to name: String
    ) throws {
        let renderer = ImageRenderer(content: view)

        renderer.scale = 3
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(size)

        let image = try #require(renderer.cgImage)
        let data = try #require(UIImage(cgImage: image).pngData())

        try data.write(to: output("6.9", name))
        try writeSmall(image, to: name)
    }

    static func writeSmall(
        _ image: CGImage,
        to name: String
    ) throws {
        let context = try #require(
            CGContext(
                data: nil,
                width: 1206,
                height: 2622,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
            )
        )

        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: 1206, height: 2622))

        let small = try #require(context.makeImage())
        let data = try #require(UIImage(cgImage: small).pngData())

        try data.write(to: output("6.3", name))
    }

    static func output(
        _ folder: String,
        _ name: String
    ) -> URL {
        URL(fileURLWithPath: directory).appending(path: "\(folder)_\(name).png")
    }
}

private enum StoreInk {
    static let ground = Color(hex: 0x1F5F5E)
    static let groundDeep = Color(hex: 0x133B3B)
    static let title = Color(hex: 0xFBF7EE)
    static let accent = Color(hex: 0xF2836B)
    static let note = Color(hex: 0xCFE6E1)
    static let bezel = Color(hex: 0x0D2223)
}

private struct StorePage: View {
    let page: SnapshotTests.Page
    let shots: [UIImage]
    let index: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            StoreRoute(index: index)

            artwork
                .frame(width: 440, height: 956, alignment: .top)
                .padding(.top, 296)

            headline
                .padding(.leading, 28)
                .padding(.top, 72)
        }
        .frame(width: 440, height: 956, alignment: .topLeading)
        .background {
            LinearGradient(
                colors: [StoreInk.ground, StoreInk.groundDeep],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipped()
    }
}

private extension StorePage {
    var headline: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(page.lines, id: \.self) { line in
                    styled(line)
                        .font(.custom("KleeOne-SemiBold", size: 44))
                        .frame(height: 58, alignment: .leading)
                }
            }

            switch page.lead {
            case .adFree:
                Text("広告なし・アカウント不要")
                    .font(.custom("ZenMaruGothic-Bold", size: 17))
                    .foregroundStyle(StoreInk.title)
                    .padding(.vertical, 4)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(StoreInk.accent)
                            .frame(height: 1.5)
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(StoreInk.accent)
                            .frame(height: 1.5)
                    }

            case let .note(note):
                Text(note)
                    .font(.custom("ZenMaruGothic-Bold", size: 16))
                    .foregroundStyle(StoreInk.note)
            }
        }
    }

    @ViewBuilder
    var artwork: some View {
        switch page.art {
        case let .phone(_, angle):
            StorePhone(shot: shots[0], width: 312)
                .rotationEffect(.degrees(angle), anchor: .top)

        case .fan:
            ZStack(alignment: .top) {
                StorePhone(shot: shots[0], width: 252)
                    .rotationEffect(.degrees(-9), anchor: .top)
                    .offset(x: -96, y: 48)

                StorePhone(shot: shots[2], width: 252)
                    .rotationEffect(.degrees(9), anchor: .top)
                    .offset(x: 96, y: 48)

                StorePhone(shot: shots[1], width: 292)
            }
        }
    }

    func styled(_ line: String) -> Text {
        let parts = line.split(separator: "*", omittingEmptySubsequences: false)

        return parts.enumerated().reduce(Text("")) { text, part in
            let color = part.offset.isMultiple(of: 2) ? StoreInk.title : StoreInk.accent
            let piece = Text(String(part.element)).foregroundStyle(color)
            return Text("\(text)\(piece)")
        }
    }
}

private struct StorePhone: View {
    let shot: UIImage
    let width: CGFloat

    var body: some View {
        let scale = width / 440

        Image(uiImage: shot)
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .clipShape(.rect(cornerRadius: 56 * scale))
            .padding(9 * scale)
            .background(StoreInk.bezel, in: .rect(cornerRadius: 64 * scale))
            .overlay {
                RoundedRectangle(cornerRadius: 64 * scale)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.35), radius: 24, y: 16)
    }
}

private struct StoreRoute: View {
    let index: Int

    var body: some View {
        Canvas { context, size in
            let start = CGFloat(index) * size.width
            let dash = StrokeStyle(lineWidth: 3, lineCap: .round, dash: [2, 10])
            var path = Path()

            for step in 0...110 {
                let x = start + CGFloat(step) * size.width / 100 - size.width * 0.05
                let point = CGPoint(x: x - start, y: Self.height(at: x))

                if step == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }

            context.stroke(
                path,
                with: .color(StoreInk.title.opacity(0.22)),
                style: dash
            )

            for station in stride(from: 110, through: 2200, by: 260) {
                let x = CGFloat(station) - start
                let y = Self.height(at: CGFloat(station))
                let dot = CGRect(x: x - 6, y: y - 6, width: 12, height: 12)

                context.fill(Path(ellipseIn: dot), with: .color(StoreInk.accent.opacity(0.55)))
            }
        }
    }

    static func height(at x: CGFloat) -> CGFloat {
        250 + 26 * sin(x / 150) + 14 * sin(x / 61)
    }
}
