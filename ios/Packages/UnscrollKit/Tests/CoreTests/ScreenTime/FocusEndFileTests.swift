import Core
import Foundation
import Testing

struct FocusEndFileTests {
    private let file = FocusEndFile(
        url: FileManager.default.temporaryDirectory.appending(path: "focus-ends-at-\(UUID())")
    )

    @Test
    func readsTheWrittenEnd() throws {
        let end = Date(timeIntervalSince1970: 1_000_000)

        try file.write(end)

        #expect(file.read() == end)
        file.remove()
    }

    @Test
    func readsNothingWhenNoFileIsWritten() {
        #expect(file.read() == nil)
    }

    @Test
    func readsNothingAfterRemoving() throws {
        try file.write(Date(timeIntervalSince1970: 1_000_000))

        file.remove()

        #expect(file.read() == nil)
    }
}
