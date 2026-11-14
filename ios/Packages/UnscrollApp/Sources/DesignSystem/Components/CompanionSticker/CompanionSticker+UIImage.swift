import Core
import UIKit

public extension CompanionSticker {
    static func uiImage(
        of companion: Companion,
        pose: Companion.Pose,
        side: CGFloat
    ) -> UIImage? {
        guard let art = UIImage(named: companion.artName(pose), in: .module, with: nil) else {
            return nil
        }

        let size = CGSize(width: side, height: side)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            context.cgContext.interpolationQuality = .none
            art.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
