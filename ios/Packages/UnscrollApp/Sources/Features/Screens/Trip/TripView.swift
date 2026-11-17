import Core
import DesignSystem
import SwiftUI

public struct TripView: View {
    private let model: RoomModel

    public init(model: RoomModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 0) {
            scenery

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
                    CompanionSticker(companion: companion, pose: .walk, size: 96)
                        .position(x: size.width / 2, y: size.height * TripScenery.roadLine - 48)
                }
            }
        }
    }

    func panel(_ trip: Trip) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    Text(headline(at: context.date))
                        .font(.headline)
                        .foregroundStyle(Palette.ink)

                    progressBlock(trip, at: context.date)
                }
            }

            Text("選んだアプリはお休み中")
                .font(.footnote)
                .foregroundStyle(Palette.muted)

            Button("旅を切り上げる（進んだ分は残る）", role: .destructive) {
                model.stopTrip()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.paper, in: RoundedRectangle(cornerRadius: 24))
        .offset(y: -Spacing.large)
    }

    func progressBlock(
        _ trip: Trip,
        at now: Date
    ) -> some View {
        let remaining = max(0, Int(ceil(trip.plannedEnd.timeIntervalSince(now))))
        let planned = Double(trip.plannedMinutes * 60)
        let elapsed = min(max(now.timeIntervalSince(trip.startedAt), 0), planned)

        return VStack(alignment: .leading, spacing: Spacing.small) {
            Text(String(format: "%02d:%02d", remaining / 60, remaining % 60))
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Palette.ink)

            ProgressView(value: elapsed, total: planned)
                .tint(Palette.teal)

            HStack {
                Text("この旅 \(trip.kilometers(at: now)) km")

                Spacer()

                Text(distanceToNext(at: now))
            }
            .font(.subheadline)
            .foregroundStyle(Palette.muted)
        }
    }

    func sceneryLandmark(at now: Date) -> Landmark? {
        let total = model.kilometers(at: now)
        return model.journey.nextLandmark(after: total) ?? model.journey.landmarks.last
    }

    func headline(at now: Date) -> String {
        let total = model.kilometers(at: now)

        guard let landmark = model.journey.nextLandmark(after: total) else {
            return "京都を歩いています"
        }

        return "\(landmark.name)へ向かっています"
    }

    func distanceToNext(at now: Date) -> String {
        let total = model.kilometers(at: now)

        guard let landmark = model.journey.nextLandmark(after: total) else {
            return "京都に着きました"
        }

        return "\(landmark.name)まで \((landmark.kilometer - total).formatted()) km"
    }
}
