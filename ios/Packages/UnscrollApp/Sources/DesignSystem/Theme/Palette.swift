import SwiftUI

public enum Palette {
    public static let paper = Color(hex: 0xF7F3EA)
    public static let ink = Color(hex: 0x1F3A3D)
    public static let teal = Color(hex: 0x2F6F73)
    public static let muted = Color(hex: 0x5D716F)
    public static let card = Color(hex: 0xFFFFFF)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
