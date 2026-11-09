import Core
import DesignSystem
import SwiftUI

public struct PostcardAlbumView: View {
    @State private var model: PostcardAlbumModel

    @Environment(\.scenePhase) private var scenePhase

    public init(model: PostcardAlbumModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    header

                    LazyVGrid(columns: columns, spacing: Spacing.medium) {
                        ForEach(model.entries, id: \.landmark.name) { entry in
                            postcard(entry)
                        }
                    }
                }
                .padding(Spacing.medium)
            }
            .background(Palette.paper)
            .navigationTitle("絵はがき")
            .navigationDestination(for: Landmark.self) { landmark in
                if let arrival = model.arrival(at: landmark) {
                    LandmarkArrivalView(arrival: arrival) { isDecorated in
                        model.setDecorated(isDecorated, landmark: landmark)
                    }
                }
            }
            .onAppear {
                model.refresh()
            }
            .onChange(of: scenePhase) {
                model.refresh()
            }
            .refreshable {
                model.refresh()
            }
        }
    }
}

private extension PostcardAlbumView {
    var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: Spacing.medium),
            GridItem(.flexible(), spacing: Spacing.medium)
        ]
    }

    var header: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text(model.journey.name)
                    .font(.title3.bold())
                    .foregroundStyle(Palette.ink)

                Spacer()

                Text("\(model.collectedCount) / \(model.totalCount) 枚")
                    .font(.headline)
                    .foregroundStyle(Palette.teal)
            }

            ProgressView(
                value: Double(model.collectedCount),
                total: Double(max(1, model.totalCount))
            )
            .tint(Palette.teal)
        }
    }

    @ViewBuilder
    func postcard(_ entry: PostcardAlbumModel.Entry) -> some View {
        if let arrival = entry.arrival {
            NavigationLink(value: entry.landmark) {
                collected(entry.landmark, arrival: arrival)
            }
            .buttonStyle(.plain)
        } else {
            uncollected(entry)
        }
    }

    func collected(
        _ landmark: Landmark,
        arrival: Arrival
    ) -> some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            PostcardArt(landmark: landmark)

            HStack(spacing: 4) {
                Text(landmark.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if arrival.isDecorated {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(Palette.coral)
                        .accessibilityLabel("部屋に飾っている")
                }
            }

            Text(arrivedDate(arrival))
                .font(.caption)
                .foregroundStyle(Palette.muted)
        }
        .padding(Spacing.small)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 12))
        .rotationEffect(.degrees(-1))
    }

    func uncollected(_ entry: PostcardAlbumModel.Entry) -> some View {
        let dash = StrokeStyle(lineWidth: 1.5, dash: [5, 4])

        return VStack(alignment: .leading, spacing: Spacing.small) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Palette.muted.opacity(0.5), style: dash)
                .overlay {
                    Text("?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.muted.opacity(0.6))
                }
                .aspectRatio(4 / 3, contentMode: .fit)

            Text(entry.landmark.name)
                .font(.subheadline.bold())
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(remainingNote(entry.remainingKilometers))
                .font(.caption)
                .foregroundStyle(Palette.muted)
        }
        .padding(Spacing.small)
        .background(Palette.card.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }

    func remainingNote(_ kilometers: Int) -> String {
        guard kilometers > 0 else {
            return "旅が終わると届く"
        }

        return "あと \(kilometers) km"
    }

    func arrivedDate(_ arrival: Arrival) -> String {
        let format = Date.VerbatimFormatStyle(
            format: "\(year: .defaultDigits)/\(month: .defaultDigits)/\(day: .defaultDigits) に届いた",
            timeZone: .current,
            calendar: .current
        )

        return arrival.arrivedAt.formatted(format)
    }
}
