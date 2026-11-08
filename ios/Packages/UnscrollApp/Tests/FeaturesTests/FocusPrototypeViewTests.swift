import Features
import Testing

@MainActor
struct FocusPrototypeViewTests {
    @Test
    func makesBody() {
        _ = FocusPrototypeView().body
    }
}
