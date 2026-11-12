import DesignSystem
import Features
import Store
import SwiftUI

public struct MainView: View {
    @State private var room: RoomModel
    @State private var journeyMap: JourneyMapModel
    @State private var postcardAlbum: PostcardAlbumModel
    @State private var settings: SettingsModel
    @State private var needsCompanion: Bool

    private let database: AppDatabase

    public init(database: AppDatabase) {
        let hasCompanion = (try? database.companion()) != nil

        _room = State(initialValue: RoomModel(database: database))
        _journeyMap = State(initialValue: JourneyMapModel(database: database))
        _postcardAlbum = State(initialValue: PostcardAlbumModel(database: database))
        _settings = State(initialValue: SettingsModel(database: database))
        _needsCompanion = State(initialValue: !hasCompanion)

        self.database = database
    }

    public var body: some View {
        TabView {
            RoomView(model: room)
                .tabItem {
                    Label("部屋", systemImage: "house")
                }

            JourneyMapView(model: journeyMap)
                .tabItem {
                    Label("地図", systemImage: "map")
                }

            PostcardAlbumView(model: postcardAlbum)
                .tabItem {
                    Label("絵はがき", systemImage: "photo.on.rectangle")
                }

            SettingsView(model: settings)
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
        .tint(Palette.teal)
        .preferredColorScheme(.light)
        .fullScreenCover(isPresented: $needsCompanion) {
            CompanionPickerView(
                model: CompanionPickerModel(database: database),
                isFirstTime: true,
                onSaved: {
                    room.refresh()
                    settings.refresh()
                }
            )
        }
    }
}
