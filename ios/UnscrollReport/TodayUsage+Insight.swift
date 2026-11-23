import Core
import DesignSystem
import FamilyControls
import Foundation
import SwiftUI

extension TodayUsage {
    var busiest: (hour: Int, minutes: Int)? {
        guard
            let peak = hours.max(),
            peak >= 60,
            let hour = hours.firstIndex(of: peak)
        else {
            return nil
        }

        return (hour, Int(peak / 60))
    }

    var comparison: (text: String, symbol: String, tint: Color)? {
        guard let yesterdayTotal else {
            return nil
        }

        let difference = Int((total - yesterdayTotal) / 60)

        if difference == 0 {
            return ("昨日の同じ時刻と同じくらい", "equal", Palette.muted)
        }

        if difference < 0 {
            return ("昨日の同じ時刻より \(-difference) 分少ないです", "arrow.down", Palette.tealDeep)
        }

        return ("昨日の同じ時刻より \(difference) 分多いです", "arrow.up", Palette.coralDeep)
    }

    var firstPickupText: String {
        guard let firstPickup else {
            return "-"
        }

        return firstPickup.formatted(date: .omitted, time: .shortened)
    }

    var perPickup: String? {
        guard pickups > 0 else {
            return nil
        }

        let minutes = Int(total / Double(pickups) / 60)

        return minutes < 1 ? "1 分未満" : "\(minutes) 分"
    }

    var longestRest: (start: Int, length: Int)? {
        guard total > 0 else {
            return nil
        }

        let current = Calendar.current.component(.hour, from: .now)
        var best: (start: Int, length: Int)?
        var run: (start: Int, length: Int)?

        for hour in 0...min(current, hours.count - 1) {
            if hours[hour] == 0 {
                run = (run?.start ?? hour, (run?.length ?? 0) + 1)

                if let run, run.length > (best?.length ?? 0) {
                    best = run
                }
            } else {
                run = nil
            }
        }

        guard let best, best.length >= 1 else {
            return nil
        }

        return best
    }

    static func format(_ duration: TimeInterval) -> String {
        Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .narrow))
    }

    func journeyText(_ kilometers: Int) -> String {
        let reached = Journey.tokyoToKyoto.landmarks.last {
            $0.kilometer > 0 && $0.kilometer <= kilometers
        }

        guard let reached else {
            return "この時間を旅にすると \(kilometers.formatted()) km 進めたよ"
        }

        return "この時間を旅にすると \(kilometers.formatted()) km。\(reached.name)まで行けたよ"
    }
}
