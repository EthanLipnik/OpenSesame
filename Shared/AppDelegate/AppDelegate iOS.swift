//
//  AppDelegate iOS.swift
//  AppDelegate iOS
//
//  Created by Ethan Lipnik on 8/20/21.
//

import Foundation
import UIKit
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.registerForRemoteNotifications()
        return true
    }
}
