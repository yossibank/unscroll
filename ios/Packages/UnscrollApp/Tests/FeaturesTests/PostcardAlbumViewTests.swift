import FeatureModels
import Features
import Store
import Testing

@MainActor
struct PostcardAlbumViewTests {
    @Test
    func makesBody() throws {
        let model = try PostcardAlbumModel(parts: .system(AppDatabase.inMemory()))

        _ = PostcardAlbumView(model: model).body
    }
}
