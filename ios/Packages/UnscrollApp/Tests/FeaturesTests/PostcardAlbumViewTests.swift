import Features
import Store
import Testing

@MainActor
struct PostcardAlbumViewTests {
    @Test
    func makesBody() throws {
        let model = try PostcardAlbumModel(database: AppDatabase.inMemory())

        _ = PostcardAlbumView(model: model).body
    }
}
