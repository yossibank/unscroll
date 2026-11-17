import DesignSystem
import Features
import Store
import SwiftUI

public struct MainView: View {
    @State private var room: RoomModel
    @State private var journeyMap: JourneyMapModel
    @State private var postcardAlbum: PostcardAlbumModel
    @State private var settings: SettingsModel
    @State private var needsOnboarding: Bool
    @State private var tab = Tab.room
    @State private var isTabBarHidden = false

    private let database: AppDatabase

    public init(database: AppDatabase) {
        let hasCompanion = (try? database.companion()) != nil

        _room = State(initialValue: RoomModel(database: database))
        _journeyMap = State(initialValue: JourneyMapModel(database: database))
        _postcardAlbum = State(initialValue: PostcardAlbumModel(database: database))
        _settings = State(initialValue: SettingsModel(database: database))
        _needsOnboarding = State(initialValue: !hasCompanion)

        self.database = database
    }

    public var body: some View {
        TabView(selection: $tab) {
            RoomView(model: room)
                .tag(Tab.room)
                .toolbarVisibility(.hidden, for: .tabBar)

            JourneyMapView(
                model: journeyMap,
                onJourneyChanged: {
                    room.refresh()
                    postcardAlbum.refresh()
                }
            )
            .tag(Tab.map)
            .toolbarVisibility(.hidden, for: .tabBar)

            PostcardAlbumView(model: postcardAlbum)
                .tag(Tab.album)
                .toolbarVisibility(.hidden, for: .tabBar)

            SettingsView(model: settings)
                .tag(Tab.settings)
                .toolbarVisibility(.hidden, for: .tabBar)
        }
        .overlay(alignment: .top) {
            LinearGradient(
                colors: [Palette.paper, Palette.paper.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 16)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            if !isTabBarHidden {
                tabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: isTabBarHidden)
        .environment(\.tabBarHidden, $isTabBarHidden)
        .fontDesign(.rounded)
        .tint(Palette.teal)
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $needsOnboarding) {
            OnboardingView(model: OnboardingModel(database: database, settings: settings)) {
                room.refresh()
                settings.refresh()
                needsOnboarding = false
            }
        }
    }
}

private extension MainView {
    enum Tab: Hashable {
        case room
        case map
        case album
        case settings
    }
}

private extension MainView {
    var tabBar: some View {
        FloatingTabBar(
            selection: $tab,
            items: [
                FloatingTabItem(
                    tab: .room,
                    title: "部屋",
                    systemImage: "house",
                    tint: Palette.teal
                ),
                FloatingTabItem(
                    tab: .map,
                    title: "地図",
                    systemImage: "map",
                    tint: Palette.sky
                ),
                FloatingTabItem(
                    tab: .album,
                    title: "絵はがき",
                    systemImage: "envelope",
                    tint: Palette.coral
                ),
                FloatingTabItem(
                    tab: .settings,
                    title: "設定",
                    systemImage: "gearshape",
                    tint: Palette.plum
                )
            ]
        ) {
            if let companion = room.companion {
                CompanionSticker(
                    companion: companion,
                    pose: .hang,
                    size: 40,
                    breathes: false
                )
                .offset(y: 11)
            }
        }
    }
}
