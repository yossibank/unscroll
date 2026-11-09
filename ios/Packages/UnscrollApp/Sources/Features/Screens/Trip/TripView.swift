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
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 0.62, green: 0.82, blue: 0.93),
                    Color(red: 0.96, green: 0.93, blue: 0.84)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            GeometryReader { proxy in
                let width = proxy.size.width
                let height = proxy.size.height

                mountain(width: width, height: height)

                Rectangle()
                    .fill(Color(red: 0.45, green: 0.69, blue: 0.4))
                    .frame(height: height * 0.3)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                road(width: width, height: height)

                companion
                    .position(x: width / 2, y: height * 0.62)
            }

            ProvisionalMark()
                .padding(Spacing.medium)
        }
    }

    var companion: some View {
        Text("相棒（あとで）")
            .font(.caption)
            .foregroundStyle(Palette.ink)
            .padding(Spacing.medium)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Palette.ink.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
            }
    }

    func mountain(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        let baseY = height * 0.72
        let peak = CGPoint(x: width * 0.5, y: height * 0.2)
        let capY = height * 0.2 + (baseY - height * 0.2) * 0.25
        let cap = CGPoint(x: width * 0.64, y: capY)
        let capLeft = CGPoint(x: width * 0.36, y: capY)

        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: width * 0.1, y: baseY))
                path.addLine(to: peak)
                path.addLine(to: CGPoint(x: width * 0.9, y: baseY))
                path.closeSubpath()
            }
            .fill(Color(red: 0.42, green: 0.55, blue: 0.62))

            Path { path in
                path.move(to: capLeft)
                path.addLine(to: peak)
                path.addLine(to: cap)
                path.closeSubpath()
            }
            .fill(Color.white)
        }
    }

    func road(
        width: CGFloat,
        height: CGFloat
    ) -> some View {
        Path { path in
            path.move(to: CGPoint(x: width * 0.42, y: height * 0.7))
            path.addLine(to: CGPoint(x: width * 0.58, y: height * 0.7))
            path.addLine(to: CGPoint(x: width * 0.8, y: height))
            path.addLine(to: CGPoint(x: width * 0.2, y: height))
            path.closeSubpath()
        }
        .fill(Color(red: 0.85, green: 0.78, blue: 0.62))
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

        return "\(landmark.name)まで \(landmark.kilometer - total) km"
    }
}
