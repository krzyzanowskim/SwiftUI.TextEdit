
# SwiftUI TextEdit View

A proof-of-concept text edit component in SwiftUI & CoreText. No UIKit, No AppKit, no UITextView/NSTextView/UITextField involved.

*Note* Due to SwiftUI limitations (as of May 2021) it's not possible to handle keystrokes just with SwiftUI. To overcome this limitation, the `UIKeyboardViewController` is responsible for handling keys and forward to SwiftUI codebase.

If you have questions or want to reach to me, use this thread: https://twitter.com/krzyzanowskim/status/1269402396217745410

## Authors

[Marcin Krzyzanowski](http://krzyzanowskim.com)
[@krzyzanowskim](https://twitter.com/krzyzanowskim)

  
## Screenshots

![TextEdit 2021-05-03 19_00_33](https://user-images.githubusercontent.com/758033/116907452-de751980-ac41-11eb-9595-7a47f1e9a4fe.gif)


  
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
