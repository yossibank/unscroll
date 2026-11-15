import Foundation
import SwiftUI

public enum DayPeriod: CaseIterable, Sendable {
    case morning
    case day
    case evening
    case night

    public init(
        date: Date,
        calendar: Calendar = .current
    ) {
        let hour = calendar.component(.hour, from: date)

        self = switch hour {
        case 5..<9: .morning
        case 9..<16: .day
        case 16..<19: .evening
        default: .night
        }
    }
}

extension DayPeriod {
    var sky: [Color] {
        switch self {
        case .morning: [
                Color(hex: 0x78A8D6),
                Color(hex: 0xACC6E4),
                Color(hex: 0xE6D2D2),
                Color(hex: 0xFCDEBA)
            ]

        case .day: [
                Color(hex: 0x589ADC),
                Color(hex: 0x80B8EA),
                Color(hex: 0xACD2F0),
                Color(hex: 0xD8EAF0)
            ]

        case .evening: [
                Color(hex: 0x404080),
                Color(hex: 0x925C8C),
                Color(hex: 0xE67E68),
                Color(hex: 0xFCBE74)
            ]

        case .night: [
                Color(hex: 0x0A0E24),
                Color(hex: 0x121A3C),
                Color(hex: 0x1E2A56),
                Color(hex: 0x2E3A68)
            ]
        }
    }

    var light: Color {
        switch self {
        case .morning: Color(hex: 0xFFFBF8)
        case .day: .white
        case .evening: Color(hex: 0xE0CCC3)
        case .night: Color(hex: 0x6E7696)
        }
    }
}
