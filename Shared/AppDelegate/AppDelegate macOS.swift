//
//  AppDelegate macOS.swift
//  AppDelegate macOS
//
//  Created by Ethan Lipnik on 8/20/21.
//

import Foundation
import AppKit
import CloudKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.registerForRemoteNotifications()
    }
}
