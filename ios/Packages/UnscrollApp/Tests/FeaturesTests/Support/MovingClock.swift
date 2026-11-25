import FeatureModels
import Foundation
import Synchronization

final class MovingClock: Sendable {
    private let date: Mutex<Date>

    init(_ date: Date) {
        self.date = Mutex(date)
    }
}

extension MovingClock {
    var clock: ScreenClock {
        ScreenClock {
            self.date.withLock { $0 }
        }
    }

    func advance(by seconds: TimeInterval) {
        date.withLock { $0 += seconds }
    }
}
