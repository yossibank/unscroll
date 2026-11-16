import Core
import DesignSystem
import SwiftUI

struct RoomDecorSheet: View {
    @State private var tab = Tab.wall
    @State private var original: (look: RoomLook, postcards: [Landmark])

    let model: RoomModel
    let onClose: () -> Void

    init(
        model: RoomModel,
        onClose: @escaping () -> Void
    ) {
        self.model = model
        self.onClose = onClose
        _original = State(initialValue: (model.look, model.hungPostcards))
    }

    var body: some View {
        VStack(spacing: Spacing.medium) {
            HStack {
                Text("模様替え")
                    .font(.title3.weight(.heavy))

                Spacer()

                Button("元に戻す") {
                    model.look = original.look
                    model.hang(original.postcards)
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.muted)
                .disabled(!isChanged)
            }

            Picker("模様替えするもの", selection: $tab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.title)
                }
            }
            .pickerStyle(.segmented)

            ScrollView {
                switch tab {
                case .wall:
                    wallGrid

                case .floor:
                    floorGrid

                case .postcards:
                    postcardGrid
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            Button("この部屋にする") {
                onClose()
            }
            .buttonStyle(.pill)
        }
        .padding(Spacing.medium)
        .padding(.top, Spacing.small)
        .fontDesign(.rounded)
        .foregroundStyle(Palette.ink)
        .background(Palette.card)
    }
}

private extension RoomDecorSheet {
    enum Tab: CaseIterable {
        case wall
        case floor
        case postcards

        var title: String {
            switch self {
            case .wall: "壁"
            case .floor: "床"
            case .postcards: "絵はがき"
            }
        }
    }

    var wallGrid: some View {
        LazyVGrid(columns: columns(2), spacing: Spacing.small + 4) {
            ForEach(RoomLook.Wall.allCases) { wall in
                swatchButton(
                    wall.name,
                    isSelected: model.look.wall == wall,
                    height: 64
                ) {
                    model.look.wall = wall
                } swatch: {
                    wall.swatch
                }
            }
        }
    }

    var floorGrid: some View {
        LazyVGrid(columns: columns(3), spacing: Spacing.small + 4) {
            ForEach(RoomLook.Floor.allCases) { floor in
                swatchButton(
                    floor.name,
                    isSelected: model.look.floor == floor,
                    height: 72
                ) {
                    model.look.floor = floor
                } swatch: {
                    floor.swatch
                }
            }
        }
    }

    var postcardGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Text("押した順に左から飾る")

                Spacer()

                Text("\(model.hungPostcards.count) / \(model.postcardLimit)")
                    .foregroundStyle(Palette.tealDeep)
                    .monospacedDigit()
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(Palette.muted)

            LazyVGrid(columns: columns(3), spacing: Spacing.small + 4) {
                ForEach(model.journey.landmarks.dropFirst(), id: \.name) { landmark in
                    postcardButton(landmark)
                }
            }

            Text("まだ着いていない名所は、着くと選べる")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Palette.muted)
        }
    }

    func swatchButton(
        _ name: String,
        isSelected: Bool,
        height: CGFloat,
        action: @escaping () -> Void,
        @ViewBuilder swatch: () -> some View
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.small) {
                swatch()
                    .frame(height: height)
                    .clipShape(.rect(cornerRadius: 12))

                Text(name)
                    .font(.subheadline.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 4)
            }
            .padding(Spacing.small)
            .background(isSelected ? Palette.tealSoft : Palette.paper, in: .rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(isSelected ? Palette.teal : .clear, lineWidth: 3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    func postcardButton(_ landmark: Landmark) -> some View {
        let isArrived = model.arrivals.contains { $0.landmark == landmark }
        let order = model.hungPostcards.firstIndex(of: landmark)

        return Button {
            model.toggleHung(landmark)
        } label: {
            VStack(spacing: 4) {
                if isArrived {
                    LandmarkArt(landmark: landmark)
                        .clipShape(.rect(cornerRadius: 8))
                } else {
                    Text("?")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Palette.muted)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(LandmarkArt.aspectRatio, contentMode: .fit)
                        .background(Palette.paperDeep, in: .rect(cornerRadius: 8))
                }

                Text(landmark.name)
                    .font(.caption2.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(6)
            .background(
                order != nil ? Palette.tealSoft : Palette.paper,
                in: .rect(cornerRadius: 16)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(order != nil ? Palette.teal : .clear, lineWidth: 3)
            }
            .overlay(alignment: .topTrailing) {
                if let order {
                    Text("\(order + 1)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Palette.teal, in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(.white, lineWidth: 2)
                        }
                        .offset(x: 4, y: -6)
                }
            }
            .opacity(isArrived ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .disabled(!isArrived)
        .accessibilityLabel(landmark.name)
        .accessibilityValue(order.map { "\($0 + 1) 番目に飾っている" } ?? "")
    }
}

private extension RoomDecorSheet {
    var isChanged: Bool {
        model.look != original.look || model.hungPostcards != original.postcards
    }

    func columns(_ count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: Spacing.small + 4), count: count)
    }
}
