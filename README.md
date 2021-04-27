
# SwiftUI TextEdit View

A proof-of-concept implementation of editable text component in SwiftUI using CoreText for text layout. 

Due to SwiftUI limitations (as of May 2021) it's not possible to handle keystrokes just with SwiftUI. To overcome this limitation, the `UIKeyboardViewController` is responsible for handling keys and forward to SwiftUI codebase.

## Authors

[Marcin Krzyzanowski](http://krzyzanowskim.com)
[@krzyzanowskim](https://twitter.com/krzyzanowskim)

  
## Screenshots

![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)

  
## Usage/Examples

```swift
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
```

  
## FAQ

#### How?

CoreText + SwiftUI.

#### Why?

For fun and profit.

  
## Related

Here are some related projects

[CoreTextSwift](https://github.com/krzyzanowskim/CoreTextSwift)
