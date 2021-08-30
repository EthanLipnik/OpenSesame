//
//  UserSettings.swift
//  UserSettings
//
//  Created by Ethan Lipnik on 8/30/21.
//

import Combine
import Foundation
#if os(iOS)
import UIKit
#endif

class UserSettings: ObservableObject {
    static let `default` = UserSettings()
    
#if os(iOS) && !EXTENSION
    @Published var selectedIcon: String = {
        return UserDefaults.standard.string(forKey: "selectedIcon") ?? "Default"
    }() {
        didSet {
            UserDefaults.standard.set(selectedIcon, forKey: "selectedIcon")
            
            UIApplication.shared.setAlternateIconName(selectedIcon != "Default" ? selectedIcon : nil)
        }
    }
#endif
}
