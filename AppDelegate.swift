import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Makes the app menu-bar-only (no Dock icon, no windows)
        NSApp.setActivationPolicy(.accessory)

        // Create the menu bar item
        statusBarController = StatusBarController()
    }
}
