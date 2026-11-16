import SwiftUI

public struct PillButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        PillButtonFace(label: configuration.label, isPressed: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == PillButtonStyle {
    static var pill: PillButtonStyle {
        PillButtonStyle()
    }
}

private struct PillButtonFace<Label: View>: View {
    @Environment(\.isEnabled) private var isEnabled

    let label: Label
    let isPressed: Bool

    var body: some View {
        label
            .font(.subheadline.weight(.heavy))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(isEnabled ? Color.white : Palette.muted)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(face, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(rim, lineWidth: 1)
            }
            .shadow(color: glow, radius: 10, y: 8)
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.15), value: isPressed)
    }
}

private extension PillButtonFace {
    var face: AnyShapeStyle {
        guard isEnabled else {
            return AnyShapeStyle(Palette.paperDeep)
        }

        let gradient = LinearGradient(
            colors: [Palette.coralLight, Palette.coral],
            startPoint: .top,
            endPoint: .bottom
        )

        return AnyShapeStyle(gradient)
    }

    var rim: LinearGradient {
        let top = Color.white.opacity(isEnabled ? 0.45 : 0)

        return LinearGradient(
            colors: [top, .clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    var glow: Color {
        isEnabled ? Palette.coral.opacity(0.4) : .clear
    }
}

#Preview {
    VStack(spacing: 16) {
        Button("こむぎと 25 分 旅に出る") {}
            .buttonStyle(.pill)

        Button("こむぎと 25 分 旅に出る") {}
            .buttonStyle(.pill)
            .disabled(true)
    }
    .padding()
    .background(PaperBackdrop())
}
