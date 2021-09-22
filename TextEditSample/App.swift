//
//  AppDelegate.swift
//  TextEdit
//
//  Created by Marcin Krzyzanowski on 31/05/2020.
//  Copyright © 2020 Marcin Krzyzanowski. All rights reserved.
//

import UIKit
import SwiftUI

@main
struct TextEditSample: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            TextEditingView()
        }
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate {
    //
}
