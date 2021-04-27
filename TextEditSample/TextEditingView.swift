import SwiftUI
import TextEdit

struct TextEditingView: View {
    @State private var text = "type here...\n"
    @State private var font = UIFont.preferredFont(forTextStyle: .body) as CTFont
    @State private var carretWidth = 2.0 as CGFloat

    var body: some View {
        TextEdit(
            text: $text,
            font: $font,
            carretWidth: $carretWidth
        )
    }
}

