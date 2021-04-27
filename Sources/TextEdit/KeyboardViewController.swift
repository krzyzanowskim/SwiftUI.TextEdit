import Foundation
import SwiftUI
import UIKit

extension UIResponder {
    static let pressPressesBegan = NSNotification.Name("OMOMUIPressPressesBeganNotification")
    static let pressPressesEnded = NSNotification.Name("OMOMUIPressPressesEndedNotification")
}

private class UIKeyboardViewController: UIViewController {
    override func pressesBegan(_ presses: Set<UIPress>, with _: UIPressesEvent?) {
        NotificationCenter.default.post(name: UIResponder.pressPressesBegan, object: presses)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with _: UIPressesEvent?) {
        NotificationCenter.default.post(name: UIResponder.pressPressesEnded, object: presses)
    }

    override func pressesChanged(_ presses: Set<UIPress>, with _: UIPressesEvent?) {
        print("pressesChanged \(presses)")
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with _: UIPressesEvent?) {
        print("pressesCancelled \(presses)")
    }
}

struct KeyboardView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        UIKeyboardViewController()
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}
