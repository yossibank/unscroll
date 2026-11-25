import Core
import DesignSystem
import FeatureModels
import SwiftUI

public struct TripView: View {
    private let model: RoomModel

    public init(model: RoomModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            scenery
                .frame(maxHeight: .infinity)

            if let trip = model.progress?.activeTrip {
                panel(trip)
            }
        }
        .background(Palette.paper)
        .task(id: model.progress?.activeTrip?.id) {
            guard let end = model.tripEndsAt else {
                return
            }

            let seconds = max(0, end.timeIntervalSinceNow)
            try? await Task.sleep(for: .seconds(seconds))

            if !Task.isCancelled {
                model.refresh()
            }
        }
    }
}

private extension TripView {
    var scenery: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            GeometryReader { proxy in
                let size = proxy.size

                if let landmark = sceneryLandmark(at: context.date) {
                    TripScenery(
                        landmark: landmark,
                        period: DayPeriod(date: context.date)
                    )
                }

                if let companion = model.companion {
                    CompanionWalker(companion: companion, size: 96)
                        .position(x: size.width / 2, y: size.height * TripScenery.roadLine - 48)
                }

                if let remark = model.tripJourney
                    .nextLandmark(after: model.kilometers(at: context.date))?.remark {
                    bubble(remark)
                        .position(x: size.width * 0.4, y: size.height * 0.3)
                }
            }
        }
        .overlay(alignment: .topLeading) {
            TagPill(
                "旅の途中",
                systemImage: "figure.walk",
                tint: Palette.tealDeep,
                wash: Palette.card
            )
            .padding(Spacing.medium)
        }
        .overlay(alignment: .topTrailing) {
            if let trip = model.progress?.activeTrip {
                TagPill(
                    "\(clock(trip.startedAt)) 発",
                    systemImage: "clock.fill",
                    tint: Palette.coralDeep,
                    wash: Palette.card
                )
                .padding(Spacing.medium)
            }
        }
    }

    var awayBand: some View {
        HStack(spacing: Spacing.medium) {
            HStack(spacing: 4) {
                Image(systemName: "iphone.gen3")

                Image(systemName: "zzz")
                    .font(.footnote.weight(.bold))
            }
            .font(.title3)
            .foregroundStyle(Palette.plumDeep)

            VStack(alignment: .leading, spacing: 2) {
                Text("スマホはお留守番中")
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Palette.ink)

                Text("選んだアプリはお休み")
                    .font(.caption)
                    .foregroundStyle(Palette.muted)
            }

            Spacer(minLength: 0)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.plumSoft, in: RoundedRectangle(cornerRadius: 16))
    }

    func bubble(_ remark: String) -> some View {
        let text = Text(remark)
            .handwritingFont(size: 15)
            .foregroundStyle(Palette.ink)
            .multilineTextAlignment(.leading)

        return ViewThatFits(in: .horizontal) {
            text
                .fixedSize(horizontal: true, vertical: false)

            text
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 200, alignment: .leading)
        .padding(.horizontal, Spacing.medium)
        .padding(.vertical, Spacing.small + 2)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Palette.shadow, radius: 6, y: 4)
        .rotationEffect(.degrees(-3))
    }

    func panel(_ trip: Trip) -> some View {
        VStack(spacing: Spacing.medium) {
            ticket(trip)

            awayBand

            Button("旅を切り上げる（進んだ分は残ります）", role: .destructive) {
                model.stopTrip()
            }
            .font(.footnote.weight(.bold))
            .buttonStyle(.plain)
            .foregroundStyle(Palette.muted)
            .frame(maxWidth: .infinity)
        }
        .padding(Spacing.medium)
        .frame(maxWidth: .infinity)
        .background(
            Palette.paper,
            in: UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
        )
        .offset(y: -Spacing.large)
    }

    func ticket(_ trip: Trip) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let remaining = max(0, Int(ceil(trip.plannedEnd.timeIntervalSince(now))))
            let planned = trip.plannedDuration
            let elapsed = min(max(now.timeIntervalSince(trip.startedAt), 0), planned)

            VStack(alignment: .leading, spacing: 4) {
                Text("旅のきっぷ")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Palette.teal)
                    .tracking(2)

                route(trip, at: now)

                HStack(alignment: .firstTextBaseline, spacing: Spacing.small) {
                    Text(countdown(remaining))
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("のこり")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Palette.muted)
                }

                Text("\(clock(trip.plannedEnd)) に着く予定")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)

                CutLine()
                    .stroke(Palette.floorEdge, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .frame(height: 1.5)
                    .padding(.vertical, Spacing.small)

                TicketGauge(ratio: planned > 0 ? elapsed / planned : 0)

                HStack(spacing: Spacing.small) {
                    TagPill(
                        "この旅 \(trip.kilometers(at: now)) km",
                        systemImage: "figure.walk",
                        tint: Palette.coralDeep,
                        wash: Palette.coralSoft
                    )

                    TagPill(
                        distanceToNext(trip, at: now),
                        systemImage: "flag.fill",
                        tint: Palette.tealDeep,
                        wash: Palette.tealSoft
                    )
                }
                .padding(.top, 4)
            }
            .padding(Spacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Palette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Palette.shadow, radius: 12, y: 8)
    }

    func route(
        _ trip: Trip,
        at now: Date
    ) -> some View {
        let total = model.kilometers(at: now)
        let journey = model.tripJourney
        let start = trip.isPractice
            ? journey.landmarks.first
            : journey.landmarks.last { $0.kilometer <= total }
        let next = trip.isPractice
            ? journey.landmarks.last
            : journey.nextLandmark(after: total)

        return HStack(spacing: Spacing.small) {
            Text(start?.name ?? "")

            if let next {
                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.black))
                    .foregroundStyle(Palette.coral)

                Text(next.name)
            }
        }
        .journalTitleFont(size: 17)
        .foregroundStyle(Palette.ink)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    func countdown(_ seconds: Int) -> String {
        guard seconds >= 3600 else {
            return String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }

        return String(format: "%d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60)
    }

    func clock(_ date: Date) -> String {
        let format = Date.VerbatimFormatStyle(
            format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
            timeZone: .current,
            calendar: .current
        )

        return date.formatted(format)
    }

    func sceneryLandmark(at now: Date) -> Landmark? {
        guard model.progress?.activeTrip?.isPractice != true else {
            return Journey.practiceStation
        }

        let total = model.kilometers(at: now)
        return model.journey.nextLandmark(after: total) ?? model.journey.landmarks.last
    }

    func distanceToNext(
        _ trip: Trip,
        at now: Date
    ) -> String {
        let total = model.kilometers(at: now)
        let journey = model.tripJourney

        if trip.isPractice {
            let seconds = max(0, Int(ceil(trip.plannedEnd.timeIntervalSince(now))))
            return "\(journey.landmarks.last?.name ?? "")まで あと \(seconds) 秒"
        }

        guard let landmark = journey.nextLandmark(after: total) else {
            return "\(journey.landmarks.last?.name ?? "")に着きました"
        }

        return "\(landmark.name)まで \((landmark.kilometer - total).formatted()) km"
    }
}

private struct CutLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        return path
    }
}
