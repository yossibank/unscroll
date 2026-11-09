import Features
import Testing

@MainActor
struct PostcardAlbumViewTests {
    @Test
    func makesBody() {
        _ = PostcardAlbumView().body
    }
}
