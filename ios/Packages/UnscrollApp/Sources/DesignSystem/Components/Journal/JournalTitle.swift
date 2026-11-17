import SwiftUI

public struct JournalTitle: View {
    private let title: String
    private let note: String

    public init(
        _ title: String,
        note: String
    ) {
        self.title = title
        self.note = note
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .journalTitleFont(size: 28)
                .foregroundStyle(Palette.ink)
                .journalMarker()
                .accessibilityAddTraits(.isHeader)

            Text(note)
                .handwritingFont(size: 13)
                .foregroundStyle(Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public extension View {
    func journalMarker() -> some View {
        padding(.horizontal, 4)
            .background(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Palette.sun.opacity(0.55))
                    .frame(height: 12)
                    .offset(y: -4)
            }
    }
}

#Preview {
    JournalTitle("絵はがき帳", note: "日本の世界遺産めぐり")
        .padding()
        .background(PaperBackdrop())
}
