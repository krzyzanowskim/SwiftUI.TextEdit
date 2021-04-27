import CoreText
import CoreTextSwift
import SwiftUI

// TODO:
//  - carret position expressed in characterIndex, instead CGPoint
//  - update (visually) carret possition as soon as index change
//  - insert text at the carret position
//  - selection

public struct TextEdit: View {
    private struct DragState: Equatable {
        var location: CGPoint = .zero
        var lastLineHeight: CGFloat = .zero

        static let zero = DragState()
    }

    private struct CarretState: Equatable {
        var location: CGPoint = .zero
        var height: CGFloat = .zero
    }

    @Binding public var text: String
    @Binding public var font: CTFont
    @Binding public var carretWidth: CGFloat

    // Text frame is calculated in MyPreferenceViewSetter
    // then propagated to ancestors. Has to be that way
    // because we need width at that point
    @State private var textFrame: CTFrame? // cached here
    @State private var textFrameBox: CGRect? // cached boundingBoxOfPath
    @State private var lineOrigins: [CGPoint] = [] // cached

    @State private var carret = CarretState()
    @GestureState private var drag: DragState = .zero

    public init(text: Binding<String>, font: Binding<CTFont>, carretWidth: Binding<CGFloat>) {
        self._text = text
        self._font = font
        self._carretWidth = carretWidth
    }

    private var attributedString: CFAttributedString {
        CFAttributedStringCreate(nil, text as CFString, [NSAttributedString.Key.font.rawValue: font] as CFDictionary)!
    }

    private func line(at location: CGPoint) -> (idx: Int, origin: CGPoint, descent: CGFloat, line: CTLine)? {
        // calculate line height
        guard let textFrame = textFrame,
              let textFrameBox = textFrameBox,
              lineOrigins.isEmpty == false
        else {
            return nil
        }

        // adjust coordinates
        let lineOrigins = self.lineOrigins.map { linePoint -> CGPoint in
            CGPoint(x: linePoint.x, y: textFrameBox.maxY - linePoint.y)
        }

        // find the line. origins come with height only (for our rect layout)
        var prevY: CGFloat = 0
        for (lineIdx, lineOrigin) in lineOrigins.enumerated() {
            let line = textFrame.lines()[lineIdx]
            let (_, descent, _) = line.typographicBounds()
            if location.y > prevY, location.y <= lineOrigin.y + descent {
                // lineIdx is the line number we found!
                return (idx: lineIdx, origin: lineOrigin, descent: descent, line: line)
            }
            prevY = lineOrigin.y + descent
        }

        return nil
    }

    private func lineTypographicHeight(at location: CGPoint) -> CGFloat {
        line(at: location)?.line.typographicHeight() ?? .zero
    }

    // adjust position to always be "in line"
    private func lineAdjustedCarretPosition(at location: CGPoint) -> CGPoint {
        guard let line = line(at: location) else {
            return location
        }

        // find character index at location
        let characterIdx = line.line.characterIndex(forPosition: location)
        let offsetForCharacter = line.line.offsetForCharacterIndex(characterIdx)

        let (_, descent, _) = line.line.typographicBounds()
        return CGPoint(x: offsetForCharacter, y: line.origin.y + descent - line.line.typographicHeight())
    }

    public var body: some View {
        KeyboardView().frame(width: 0, height: 0).background(Color.clear)
        
        GeometryReader { _ in
            GlyphsView(self.attributedString, self.textFrame)
                .simultaneousGesture(
                    DragGesture().updating(self.$drag) { value, state, _ in
                        state = DragState(location: self.lineAdjustedCarretPosition(at: value.location),
                                          lastLineHeight: self.lineTypographicHeight(at: value.location))
                    }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onEnded { _ in
                            // Here! because GestureState value is still valid (yay) and can be read
                            // It won't work from each gesture onEnded closure
                            self.carret.location = self.drag.location
                            self.carret.height = self.drag.lastLineHeight
                        }
                )
                .background(
                    MyPreferenceViewSetter(
                        attributedString: self.attributedString
                    )
                )

            // when dragging, use GestureState, then use State
            if self.drag == .zero {
                CarretView(width: self.$carretWidth)
                    .frame(height: self.carret.height) // current height should be calculated per line
                    .offset(x: self.carret.location.x, y: self.carret.location.y)
            } else {
                CarretView(width: self.$carretWidth)
                    .frame(height: self.drag.lastLineHeight) // current height should be calculated per line
                    .offset(x: self.drag.location.x, y: self.drag.location.y)
            }
        }
        .onPreferenceChange(TextPreferenceKey.self) { preferences in
            // get frame from/for GlyphsView.
            // funny enough it's called before GlyphsView body is called
            if let textFrame = preferences.first?.textFrame {
                self.textFrame = textFrame
                self.textFrameBox = textFrame.path().boundingBoxOfPath
                self.lineOrigins = textFrame.lineOrigins()

                // FIXME: not correct
                // self.carret = CarretState(location: .zero, height: self.font.ascent() + self.font.descent() + self.font.leading())

                // UPDATE CARRET HERE!

                // move carret + number of characters
                // adjust coordinates
                let lineOrigins = self.lineOrigins.map { linePoint -> CGPoint in
                    CGPoint(x: linePoint.x, y: self.textFrameBox!.maxY - linePoint.y)
                }

                // find the line of last character
                // FIXME: there's no "before" in empty string
                let lastCharacterIndex: String.Index
                if self.text.isEmpty {
                    lastCharacterIndex = self.text.startIndex
                } else {
                    lastCharacterIndex = self.text.index(before: self.text.endIndex)
                }

                for (lineIdx, line) in textFrame.lines().enumerated() {
                    if let lineRange = Range(line.stringRange(), in: self.text),
                       lineRange.contains(lastCharacterIndex)
                    {
                        // get the X offset of the last character
                        let q = NSRange(lineRange, in: self.text)
                        let lineOffsetX = line.offsetForCharacterIndex(q.upperBound)

                        let (_, descent, _) = line.typographicBounds()
                        let pos = CGPoint(x: lineOrigins[lineIdx].x + lineOffsetX,
                                          y: lineOrigins[lineIdx].y + descent - line.typographicHeight())

                        // update carret
                        // TODO: use lense here
                        self.carret = CarretState(location: pos, height: self.font.ascent() + self.font.descent() + self.font.leading())
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.pressPressesBegan), perform: { notification in
            guard let presses = notification.object as? Set<UIPress>, let press = presses.first, let key = press.key else {
                return
            }

            switch key.keyCode {
            case .keyboardDeleteOrBackspace:
                if !self.text.isEmpty {
                    self.text = String(self.text.dropLast())
                }
            case .keyboardReturnOrEnter, .keyboardReturn:
                // something wrong with new line
                // https://stackoverflow.com/questions/44683156/linecount-for-attributedstring-from-coretext-is-wrong
                // Maybe custom framesetter would help here
                self.text += "\n"
            default:
                self.text += key.characters
            }
        })
    }
}

struct MyPreferenceViewSetter: View {
    let attributedString: CFAttributedString

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: TextPreferenceKey.self,
                            value: [TextPreferenceData(rect: geometry.frame(in: .local),
                                                       // if you link against the new SDK and want to typeset text with a UTF-16 length longer than 4096,
                                                       // you now need to pass in the new option `kCTTypesetterOptionAllowUnboundedLayout`
                                                       textFrame: self.attributedString.framesetter().createFrame(geometry.frame(in: .local)),
                                                       attributedString: self.attributedString)])
        }
    }
}

struct TextPreferenceData: Equatable {
    let rect: CGRect
    let textFrame: CTFrame
    let attributedString: CFAttributedString
}

struct TextPreferenceKey: PreferenceKey {
    typealias Value = [TextPreferenceData]

    static var defaultValue: [TextPreferenceData] = []

    static func reduce(value: inout [TextPreferenceData], nextValue: () -> [TextPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

// Notes:
//
// http://unicode.org/faq/char_combmark.html
// U+01B5 LATIN CAPITAL LETTER Z WITH STROKE
// U+0327 COMBINING CEDILLA
// U+0308 COMBINING DIAERESIS
// "\u{01B5}\u{0327}\u{0308}" // Ƶ̧̈ <- broken here
// "\u{0061}\u{0328}\u{0301}" // ą́ <- broken in Xcode
// "\u{0105}\u{0301}"         // ą́ <- ok
// "Z\u{0308}"
