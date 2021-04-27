import SwiftUI

struct CarretView: View {
    @Binding var width: CGFloat

    var body: some View {
        CarretShape()
            .stroke(lineWidth: width)
            .frame(width: width)
            .foregroundColor(Color.accentColor)
    }
}

struct CarretShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
