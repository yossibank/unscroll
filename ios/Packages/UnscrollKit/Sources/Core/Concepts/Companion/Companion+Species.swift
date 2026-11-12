public extension Companion {
    enum Species: String, CaseIterable, Sendable {
        case penguin
        case tanuki
        case shiba
    }

    enum Coat: String, Sendable {
        case black
        case brown
        case dark
        case emperor
        case gray
        case king
        case red
        case sesame
        case white
    }

    enum Pose: String, Sendable {
        case walk
        case walkLeft = "walk_left"
        case blink
        case wave
        case joy
        case jump
        case sleep
        case surprise
        case slide
    }
}

public extension Companion.Species {
    var label: String {
        switch self {
        case .penguin: "ペンギン"
        case .tanuki: "たぬき"
        case .shiba: "柴犬"
        }
    }

    var defaultName: String {
        switch self {
        case .penguin: "ぺんた"
        case .tanuki: "ぽん"
        case .shiba: "こむぎ"
        }
    }

    var coats: [Companion.Coat] {
        switch self {
        case .penguin: [.gray, .black, .emperor, .king]
        case .tanuki: [.brown, .dark, .gray, .white]
        case .shiba: [.red, .black, .white, .sesame]
        }
    }

    func label(of coat: Companion.Coat) -> String {
        switch (self, coat) {
        case (.penguin, .gray): "灰（子）"
        case (.penguin, .black): "黒白"
        case (_, .emperor): "皇帝"
        case (_, .king): "キングの子"
        case (_, .brown): "茶"
        case (_, .dark): "こげ茶"
        case (_, .gray): "灰"
        case (_, .white): "白"
        case (_, .red): "赤"
        case (_, .black): "黒"
        case (_, .sesame): "胡麻"
        }
    }
}
