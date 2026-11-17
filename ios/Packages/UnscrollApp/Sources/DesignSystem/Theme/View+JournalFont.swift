import SwiftUI

public extension View {
    func journalTitleFont(size: CGFloat) -> some View {
        font(.custom("ZenMaruGothic-Bold", size: size))
            .fontDesign(nil)
    }

    func handwritingFont(size: CGFloat) -> some View {
        font(.custom("KleeOne-SemiBold", size: size))
            .fontDesign(nil)
    }
}
