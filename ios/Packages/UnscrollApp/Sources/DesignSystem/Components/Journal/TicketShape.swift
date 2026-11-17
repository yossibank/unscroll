import SwiftUI

public struct TicketShape: Shape {
    private let stubWidth: CGFloat

    public init(stubWidth: CGFloat) {
        self.stubWidth = stubWidth
    }

    public func path(in rect: CGRect) -> Path {
        let notch: CGFloat = 8
        let x = rect.maxX - stubWidth
        let body = RoundedRectangle(cornerRadius: 16).path(in: rect)

        let top = Path(ellipseIn: CGRect(
            x: x - notch,
            y: rect.minY - notch,
            width: notch * 2,
            height: notch * 2
        ))

        let bottom = Path(ellipseIn: CGRect(
            x: x - notch,
            y: rect.maxY - notch,
            width: notch * 2,
            height: notch * 2
        ))

        return body.subtracting(top).subtracting(bottom)
    }
}
