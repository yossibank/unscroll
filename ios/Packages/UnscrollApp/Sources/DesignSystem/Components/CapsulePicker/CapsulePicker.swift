import SwiftUI

public struct CapsulePicker<Item: Hashable>: View {
    @Namespace private var capsule

    @Binding private var selection: Item

    private let items: [Item]
    private let title: (Item) -> String
    private let systemImage: ((Item) -> String)?

    public init(
        _ items: [Item],
        selection: Binding<Item>,
        title: @escaping (Item) -> String,
        systemImage: ((Item) -> String)? = nil
    ) {
        self.items = items
        self.title = title
        self.systemImage = systemImage
        _selection = selection
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(items, id: \.self) { item in
                button(item)
            }
        }
        .padding(4)
        .background(Palette.paperDeep, in: Capsule())
        .animation(.snappy, value: selection)
    }
}

private extension CapsulePicker {
    @ViewBuilder
    func label(_ item: Item) -> some View {
        if let systemImage {
            Label(title(item), systemImage: systemImage(item))
        } else {
            Text(title(item))
        }
    }

    func button(_ item: Item) -> some View {
        let isSelected = selection == item

        return Button {
            selection = item
        } label: {
            label(item)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(isSelected ? Color.white : Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Palette.teal)
                            .shadow(color: Palette.teal.opacity(0.3), radius: 6, y: 4)
                            .matchedGeometryEffect(id: "selection", in: capsule)
                    }
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
