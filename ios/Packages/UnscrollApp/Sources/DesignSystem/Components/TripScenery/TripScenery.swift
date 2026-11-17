import Core
import SwiftUI

public struct TripScenery: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let landmark: Landmark
    private let period: DayPeriod
    private let isMoving: Bool

    public init(
        landmark: Landmark,
        period: DayPeriod,
        isMoving: Bool = true
    ) {
        self.landmark = landmark
        self.period = period
        self.isMoving = isMoving
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || !isMoving)) { context in
            let seconds = isMoving ? context.date.timeIntervalSinceReferenceDate : 0

            GeometryReader { proxy in
                ZStack {
                    LinearGradient(colors: period.sky, startPoint: .top, endPoint: .bottom)

                    if proxy.size.height > 0 {
                        ForEach(SceneryLayer.allCases, id: \.self) { layer in
                            strip(layer, size: proxy.size, seconds: seconds)
                        }
                        .colorMultiply(period.light)
                    }
                }
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

public extension TripScenery {
    static let roadLine: CGFloat = 182 / 210
}

private extension TripScenery {
    static let aspectRatio: CGFloat = 320 / 210

    func strip(
        _ layer: SceneryLayer,
        size: CGSize,
        seconds: TimeInterval
    ) -> some View {
        let tile = size.height * Self.aspectRatio
        let shift = (seconds * layer.speed * size.height).truncatingRemainder(dividingBy: tile)
        let count = Int((size.width / tile).rounded(.up)) + 1

        return HStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { _ in
                Image(landmark.sceneryArtName(layer), bundle: .module)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: tile, height: size.height)
            }
        }
        .offset(x: -shift)
        .frame(width: size.width, height: size.height, alignment: .leading)
    }
}

private extension SceneryLayer {
    var speed: Double {
        switch self {
        case .far: 0.006
        case .mid: 0.02
        case .near: 0.08
        }
    }
}
