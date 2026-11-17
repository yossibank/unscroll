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
                    JournalTitle("絵はがき帳", note: model.journey.name)

                    PostcardStampRally(entries: model.entries)

                    LazyVGrid(columns: columns, spacing: Spacing.large) {
                        ForEach(
                            Array(model.entries.enumerated()),
                            id: \.element.landmark.name
                        ) { index, entry in
                            postcard(entry, index: index)
                        }
                    }
                    .padding(.top, Spacing.small)
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

    @ViewBuilder
    func postcard(
        _ entry: PostcardAlbumModel.Entry,
        index: Int
    ) -> some View {
        if entry.isCollected {
            NavigationLink(value: entry.landmark) {
                PostcardAlbumCard(entry: entry, index: index)
            }
            .buttonStyle(.plain)
        } else {
            PostcardAlbumCard(entry: entry, index: index)
        }
    }
}
