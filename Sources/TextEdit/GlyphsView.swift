import CoreText
import CoreTextSwift
import SwiftUI

// View because it not a single shape (colors and other things is not a single shape)
struct GlyphsView: View {
    var attributedString: CFAttributedString
    var textFrame: CTFrame?
    private let invertY: CGFloat = -1 // invert for macOS

    init(_ attributedString: CFAttributedString, _ textFrame: CTFrame?) {
        self.attributedString = attributedString
        self.textFrame = textFrame
    }

    var body: some View {
        guard let textFrame = textFrame else {
            return Path()
        }

        var path = Path()
        let textFrameBox = textFrame.path().boundingBoxOfPath

        // transform to top-left coordinates
        let lineOrigins = textFrame.lineOrigins()
            .map { linePoint -> CGPoint in
                CGPoint(x: linePoint.x, y: textFrameBox.maxY - linePoint.y)
            }

        // draw all lines
        for (i, line) in textFrame.lines().enumerated() {
            let lineOrigin = lineOrigins[i]
            for glyphRun in line.glyphRuns() {
                let font = glyphRun.font
                let glyphs = glyphRun.glyphs()
                let glyphsPositions = glyphRun.glyphPositions()
                for (idx, glyph) in glyphs.enumerated() {
                    let positionTransform = CGAffineTransform(translationX: glyphsPositions[idx].x, y: (invertY * glyphsPositions[idx].y) + lineOrigin.y)
                        .scaledBy(x: 1, y: 1 * invertY)

                    // path is nil for space
                    if let glyphCGPath = font.path(for: glyph, transform: positionTransform) {
                        path.addPath(Path(glyphCGPath))
                    }
                }
            }
        }

        return path
    }
}
