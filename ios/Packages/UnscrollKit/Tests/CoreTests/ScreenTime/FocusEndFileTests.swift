import Core
import Foundation
import Testing

struct FocusEndFileTests {
    private let file = FocusEndFile(
        url: FileManager.default.temporaryDirectory.appending(path: "focus-ends-at-\(UUID())")
    )

    private let entry = FocusEndFile.Entry(
        endsAt: Date(timeIntervalSince1970: 1_000_000),
        activity: "focus.12"
    )

    @Test
    func readsTheWrittenEntry() throws {
        try file.write(entry)

        #expect(file.read() == entry)
        file.remove()
    }

    @Test
    func readsNothingWhenNoFileIsWritten() {
        #expect(file.read() == nil)
    }

    @Test
    func readsNothingAfterRemoving() throws {
        try file.write(entry)

        file.remove()

        #expect(file.read() == nil)
    }
}
