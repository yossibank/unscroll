import SwiftUI

public enum Palette {
    public static let paper = Color(hex: 0xFBF7EE)
    public static let paperDeep = Color(hex: 0xF3EDE0)
    public static let ink = Color(hex: 0x1F3A3D)
    public static let muted = Color(hex: 0x6E7F7C)
    public static let card = Color(hex: 0xFFFFFF)
    public static let floorEdge = Color(hex: 0xC8B48D)
    public static let teal = Color(hex: 0x2F8A86)
    public static let tealDeep = Color(hex: 0x1F5F5E)
    public static let tealSoft = Color(hex: 0xE1F1EE)
    public static let coral = Color(hex: 0xF2836B)
    public static let coralLight = Color(hex: 0xFF9C82)
    public static let coralDeep = Color(hex: 0xB4542F)
    public static let coralSoft = Color(hex: 0xFDE8E1)
    public static let sun = Color(hex: 0xF6C453)
    public static let sunDeep = Color(hex: 0xB8872A)
    public static let sunSoft = Color(hex: 0xFDF3D6)
    public static let sky = Color(hex: 0x6FB7E6)
    public static let skyDeep = Color(hex: 0x2F7DB0)
    public static let skySoft = Color(hex: 0xE3F2FB)
    public static let plum = Color(hex: 0x9B7FD1)
    public static let plumDeep = Color(hex: 0x6B4FA3)
    public static let plumSoft = Color(hex: 0xEFE9FA)
    public static let leaf = Color(hex: 0x7CC08A)
    public static let shadow = Color(hex: 0x1F3A3D).opacity(0.08)
}

public extension Palette {
    static func hour(_ hour: Int) -> Color {
        switch hour {
        case 5..<11: sun
        case 11..<18: sky
        default: plum
        }
    }
}
