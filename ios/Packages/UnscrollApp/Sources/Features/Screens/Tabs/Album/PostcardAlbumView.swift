import Core
import DesignSystem
import SwiftUI

public struct PostcardAlbumView: View {
    @State private var model: PostcardAlbumModel
    @State private var path: [Landmark] = []

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.tabBarHidden) private var tabBarHidden

    public init(model: PostcardAlbumModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    header

                    LazyVGrid(columns: columns, spacing: Spacing.medium) {
                        ForEach(
                            Array(model.entries.enumerated()),
                            id: \.element.landmark.name
                        ) { index, entry in
                            postcard(entry)
                                .rotationEffect(.degrees(index.isMultiple(of: 2) ? -1.6 : 1.4))
                        }
                    }
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.small)
                .padding(.bottom, FloatingTabBarMetrics.clearance)
            }
            .background(PaperBackdrop())
            .toolbarVisibility(.hidden, for: .navigationBar)
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
            .onChange(of: scenePhase) { _, newPhase in
                guard newPhase == .active else {
                    return
                }

                model.refresh()
            }
            .onChange(of: path.isEmpty) { _, isEmpty in
                tabBarHidden.wrappedValue = !isEmpty
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
        HStack(spacing: Spacing.medium) {
            ProgressRing(
                ratio: Double(model.collectedCount) / Double(max(1, model.totalCount)),
                label: "\(model.collectedCount)/\(model.totalCount)",
                tint: Palette.coral,
                wash: Palette.coralSoft
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(model.journey.name)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Palette.muted)

                Text("あつめた絵はがき")
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(Palette.ink)

                HStack(spacing: 4) {
                    ForEach(model.entries, id: \.landmark.name) { entry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(entry.isCollected ? Palette.coral : Palette.paperDeep)
                            .frame(width: 16, height: 16)
                    }
                }
                .accessibilityHidden(true)
            }
        }
        .roundedCard()
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
        VStack(alignment: .leading, spacing: 4) {
            PostcardArt(landmark: landmark)
                .overlay(alignment: .topTrailing) {
                    if arrival.isDecorated {
                        Image(systemName: "house.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Palette.coral)
                            .frame(width: 24, height: 28)
                            .background(.white, in: .rect(cornerRadius: 4))
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(
                                        Palette.coral,
                                        style: StrokeStyle(lineWidth: 1.5, dash: [3, 2])
                                    )
                            }
                            .padding(4)
                            .accessibilityLabel("部屋に飾っている")
                    }
                }

            Text(landmark.name)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
                .padding(.top, 4)

            Text(arrivedDate(arrival))
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 4)
        }
        .padding(Spacing.small)
        .background(Palette.card, in: .rect(cornerRadius: 20))
        .shadow(color: Palette.ink.opacity(0.1), radius: 9, y: 8)
    }

    func uncollected(_ entry: PostcardAlbumModel.Entry) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Palette.paper)
                .overlay {
                    Text(remainingNote(entry.remainingKilometers))
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(Palette.teal)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, Spacing.small)
                        .padding(.vertical, 4)
                        .background(.white, in: Capsule())
                }
                .aspectRatio(LandmarkArt.aspectRatio, contentMode: .fit)

            Text(entry.landmark.name)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
                .padding(.top, 4)

            Text(entry.remainingKilometers > 0 ? "まだ先" : "もうすぐ届く")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)
                .padding(.horizontal, 4)
        }
        .padding(Spacing.small)
        .background(Palette.card.opacity(0.7), in: .rect(cornerRadius: 20))
    }
}

private extension PostcardAlbumView {
    func remainingNote(_ kilometers: Int) -> String {
        guard kilometers > 0 else {
            return "旅が終わると届く"
        }

        return "あと \(kilometers) km"
    }

    func arrivedDate(_ arrival: Arrival) -> String {
        let format = Date.VerbatimFormatStyle(
            format: "\(month: .defaultDigits)/\(day: .defaultDigits) に届いた",
            timeZone: .current,
            calendar: .current
        )

        return arrival.arrivedAt.formatted(format)
    }
}
