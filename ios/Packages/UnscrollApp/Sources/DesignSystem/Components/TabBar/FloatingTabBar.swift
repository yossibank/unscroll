import SwiftUI

public struct FloatingTabBar<Tab: Hashable, Peek: View>: View {
    @Binding private var selection: Tab

    private let items: [FloatingTabItem<Tab>]
    private let peek: Peek

    public init(
        selection: Binding<Tab>,
        items: [FloatingTabItem<Tab>],
        @ViewBuilder peek: () -> Peek
    ) {
        _selection = selection

        self.items = items
        self.peek = peek()
    }

    public var body: some View {
        HStack(spacing: Self.spacing) {
            ForEach(items) { item in
                button(item)
            }
        }
        .background {
            GeometryReader { proxy in
                Capsule()
                    .fill(selectedTint)
                    .shadow(color: selectedTint.opacity(0.45), radius: 8, y: 6)
                    .frame(width: slotWidth(in: proxy.size.width), height: 52)
                    .position(x: peekX(in: proxy.size.width), y: proxy.size.height / 2)
            }
        }
        .overlay {
            GeometryReader { proxy in
                peek
                    .hop(trigger: selection)
                    .frame(height: 0, alignment: .bottom)
                    .position(x: peekX(in: proxy.size.width), y: 0)
            }
            .allowsHitTesting(false)
        }
        .padding(.horizontal, 8)
        .frame(height: FloatingTabBarMetrics.height)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .fill(Palette.card.opacity(0.72))
                }
                .shadow(color: Palette.ink.opacity(0.16), radius: 16, y: 12)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .animation(.spring(duration: 0.5, bounce: 0.35), value: selection)
    }
}

public struct FloatingTabItem<Tab: Hashable>: Identifiable {
    public let tab: Tab
    public let title: String
    public let systemImage: String
    public let tint: Color

    public init(
        tab: Tab,
        title: String,
        systemImage: String,
        tint: Color
    ) {
        self.tab = tab
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
    }
}

public extension FloatingTabItem {
    var id: Tab {
        tab
    }
}

public enum FloatingTabBarMetrics {
    public static let height: CGFloat = 64
    public static let clearance: CGFloat = 112
}

public extension EnvironmentValues {
    @Entry var tabBarHidden: Binding<Bool> = .constant(false)
}

private extension FloatingTabBar {
    static var spacing: CGFloat {
        4
    }

    var selectedTint: Color {
        items.first { $0.tab == selection }?.tint ?? .clear
    }

    @ViewBuilder
    func button(_ item: FloatingTabItem<Tab>) -> some View {
        let isSelected = item.tab == selection

        Button {
            selection = item.tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .symbolVariant(isSelected ? .fill : .none)
                    .frame(height: 22)

                Text(item.title)
                    .font(.caption2.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? Color.white : Palette.muted.opacity(0.8))
            .frame(maxWidth: .infinity, minHeight: 52)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func slotWidth(in width: CGFloat) -> CGFloat {
        let count = CGFloat(max(items.count, 1))
        return (width - Self.spacing * (count - 1)) / count
    }

    func peekX(in width: CGFloat) -> CGFloat {
        let slot = slotWidth(in: width)
        let index = CGFloat(items.firstIndex { $0.tab == selection } ?? 0)
        return index * (slot + Self.spacing) + slot / 2
    }
}

#Preview {
    @Previewable @State var selection = 0

    VStack {
        Spacer()

        FloatingTabBar(
            selection: $selection,
            items: [
                FloatingTabItem(
                    tab: 0,
                    title: "部屋",
                    systemImage: "house",
                    tint: Palette.teal
                ),
                FloatingTabItem(
                    tab: 1,
                    title: "絵はがき",
                    systemImage: "envelope",
                    tint: Palette.coral
                )
            ]
        ) {
            Circle()
                .fill(Palette.sun)
                .frame(width: 28, height: 28)
        }
    }
    .background(PaperBackdrop())
}
