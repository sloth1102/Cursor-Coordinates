import SwiftUI
import AppKit

@main
struct PolarMouseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // No WindowGroup at all
        Settings { } // Optional: can even remove this if you don't need a settings window
    }
}
