import DesignSystem
import FamilyControls
import SwiftUI

struct AppIcon: View {
    let app: AppUsage
    let tint: Color

    var body: some View {
        if let token = app.token {
            Label(token)
                .labelStyle(.iconOnly)
                .scaleEffect(1.4)
                .frame(width: 28, height: 28)
        } else {
            RoundedRectangle(cornerRadius: 7)
                .fill(tint)
                .frame(width: 28, height: 28)
        }
    }
}
