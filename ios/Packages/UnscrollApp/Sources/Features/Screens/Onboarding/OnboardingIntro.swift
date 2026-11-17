import Core
import DesignSystem
import SwiftUI

struct OnboardingIntro: View {
    let page: OnboardingModel.Page

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            Spacer(minLength: 0)

            picture
                .padding(.horizontal, 4)

            VStack(alignment: .leading, spacing: Spacing.small + 4) {
                OnboardingHeadline(lines: lines)

                Text(message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Palette.muted)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, Spacing.small)

            Spacer(minLength: 0)
        }
    }
}

private extension OnboardingIntro {
    static let sample = Companion.starter

    static let fujisan = Journey.all
        .flatMap(\.landmarks)
        .first { $0.artKey == "fujisan" }

    @ViewBuilder
    var picture: some View {
        switch page {
        case .walk:
            walkPicture

        case .postcard:
            postcardPicture

        case .usage:
            OnboardingUsageSample()

        default:
            TapedPhoto(caption: "相棒と、部屋から出かける", tilt: 1.5) {
                RoomScene(
                    companion: Self.sample,
                    look: RoomLook(),
                    pose: .wave,
                    window: Journey.tokyoToKyoto.nextLandmark(after: 0),
                    postcards: [],
                    nextRemaining: nil,
                    souvenirs: [],
                    onPoke: {}
                )
                .allowsHitTesting(false)
            }
            .accessibilityHidden(true)
        }
    }

    var walkPicture: some View {
        VStack(spacing: Spacing.medium + 4) {
            if let geometry = JourneyMapGeometry.for(Journey.tokyoToKyoto.id) {
                TapedPaper {
                    JourneyMapCanvas(
                        journey: .tokyoToKyoto,
                        geometry: geometry,
                        kilometers: 120,
                        companion: Self.sample
                    )
                }
                .accessibilityHidden(true)
            }

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("旅のきっぷ")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Palette.teal)
                        .tracking(2)

                    HStack(spacing: Spacing.small) {
                        Text("25 分の旅")

                        Image(systemName: "arrow.right")
                            .font(.footnote.weight(.black))
                            .foregroundStyle(Palette.coral)

                        Text("25 km")
                    }
                    .journalTitleFont(size: 17)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.small + 4)
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    Text("1")
                        .journalTitleFont(size: 22)
                        .foregroundStyle(Palette.teal)

                    Text("分 = 1 km")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Palette.muted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(width: Self.stubWidth)
                .frame(maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .stroke(Palette.floorEdge, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        .frame(width: 0.5)
                        .padding(.vertical, Spacing.small)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .background(Palette.card, in: TicketShape(stubWidth: Self.stubWidth))
            .shadow(color: Palette.shadow, radius: 8, y: 4)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("1 分で 1 km 進む")
        }
    }

    var postcardPicture: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            if let fujisan = Self.fujisan {
                LandmarkArt(landmark: fujisan)
                    .clipShape(.rect(cornerRadius: 2))
                    .accessibilityHidden(true)
            }

            Text("富士山に着いたよ。\nまた いっしょに歩こうね。\n— \(Self.sample?.name ?? "")")
                .handwritingFont(size: 14)
                .foregroundStyle(Palette.ink)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)
                .padding(.trailing, 64)
        }
        .padding(Spacing.small + 4)
        .background(Palette.card, in: .rect(cornerRadius: 6))
        .shadow(color: Palette.ink.opacity(0.14), radius: 8, y: 6)
        .overlay(alignment: .bottomTrailing) {
            Postmark(date: .now)
                .padding(Spacing.medium)
        }
        .overlay(alignment: .top) {
            MaskingTape(tint: Palette.sun)
                .rotationEffect(.degrees(3))
                .offset(y: -10)
        }
        .rotationEffect(.degrees(-2))
        .padding(.horizontal, 4)
    }
}

private extension OnboardingIntro {
    static let stubWidth: CGFloat = 88

    var lines: [String] {
        switch page {
        case .walk: ["止めた時間のぶん、", "道のりを歩く"]
        case .postcard: ["名所に着くと、", "絵はがきが届く"]
        case .usage: ["1 日に、どのアプリを", "どれだけ使ったか見返せます"]
        default: ["旅に出ると、", "スマホがひと休み"]
        }
    }

    var message: String {
        switch page {
        case .walk:
            "相棒は、1 分で 1 km ずつ進みます。日本の道のりを \(Journey.all.count) 本から選べます。"

        case .postcard:
            "届いた絵はがきは、部屋に飾ったり、絵はがき帳で見返したりできます。"

        case .usage:
            "使った時間・よく使う時間帯・アプリごとの時間を、部屋のタブでいつでも見られます。旅に出る長さの目安になります。"

        default:
            "旅の長さを決めて出かけると、その間だけ、選んだアプリが止まります。"
        }
    }
}
