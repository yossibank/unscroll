import Core
import UIKit

public extension LandmarkArt {
    nonisolated static func isAvailable(for journey: Journey) -> Bool {
        journey.landmarks.allSatisfy { landmark in
            UIImage(named: landmark.artName, in: .module, with: nil) != nil
        }
    }
}
