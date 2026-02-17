import AppKit

final class StatusBarController {
    
    private var statusItem: NSStatusItem!
    private var tracking = false
    private var timer: Timer?
    
    private var mode: String = "Polar"
    private var usePiFormat = false
    
    private var menu: NSMenu!
    private var modeItem: NSMenuItem!
    private var piItem: NSMenuItem!
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "(r, θ)"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(handleClick)
        
        setupMenu()
    }
    
    // MARK: - Click Handling
    
    @objc private func handleClick() {
        if !tracking {
            startTracking()
        } else {
            showMenu()
        }
    }
    
    private func startTracking() {
        tracking = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.updateMouse()
        }
    }
    
    @objc private func turnOffTracking() {
        tracking = false
        timer?.invalidate()
        timer = nil
        updateTitleDefault()
    }
    
    // MARK: - Menu Setup
    
    private func setupMenu() {
        menu = NSMenu()
        
        modeItem = NSMenuItem(title: "Switch to Cartesian", action: #selector(toggleMode), keyEquivalent: "")
        modeItem.target = self
        menu.addItem(modeItem)
        
        piItem = NSMenuItem(title: "Show θ in terms of π", action: #selector(togglePiFormat), keyEquivalent: "")
        piItem.target = self
        menu.addItem(piItem)
        
        let offItem = NSMenuItem(title: "Turn Off Tracking", action: #selector(turnOffTracking), keyEquivalent: "")
        offItem.target = self
        menu.addItem(offItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }
    
    private func showMenu() {
        guard let button = statusItem.button else { return }
        
        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }
    
    // MARK: - Mode Toggles
    
    @objc private func toggleMode() {
        if mode == "Polar" {
            mode = "Cartesian"
            modeItem.title = "Switch to Polar"
        } else {
            mode = "Polar"
            modeItem.title = "Switch to Cartesian"
        }
        updateTitleDefault()
    }
    
    @objc private func togglePiFormat() {
        usePiFormat.toggle()
        
        if usePiFormat {
            piItem.title = "Show θ in Degrees"
        } else {
            piItem.title = "Show θ in terms of π"
        }
    }
    
    // MARK: - Mouse Updates
    
    private func updateMouse() {
        guard let screen = NSScreen.main else { return }
        
        let mousePos = NSEvent.mouseLocation
        let centerX = screen.frame.width / 2
        let centerY = screen.frame.height / 2
        
        let dx = mousePos.x - centerX
        let dy = mousePos.y - centerY
        
        let title: String
        
        if mode == "Polar" {
            let r = sqrt(dx * dx + dy * dy)
            let thetaRadians = atan2(dy, dx)
            
            if usePiFormat {
                let thetaString = formatAsPi(thetaRadians)
                title = "(\(Int(r)), \(thetaString))"
            } else {
                let thetaDegrees = thetaRadians * 180 / .pi
                title = String(format: "(%.0f, %.1f°)", r, thetaDegrees)
            }
        } else {
            title = String(format: "(%.0f, %.0f)", dx, dy)
        }
        
        DispatchQueue.main.async {
            self.statusItem.button?.title = title
        }
    }
    
    private func updateTitleDefault() {
        if mode == "Polar" {
            statusItem.button?.title = "(r, θ)"
        } else {
            statusItem.button?.title = "(x, y)"
        }
    }
    
    // MARK: - π Formatter
    
    private func formatAsPi(_ radians: Double) -> String {
        let fraction = radians / Double.pi
        
        let denominators = [1, 2, 3, 4, 6, 8, 12]
        
        for d in denominators {
            let numerator = round(fraction * Double(d))
            if abs(fraction - numerator / Double(d)) < 0.02 {
                
                if numerator == 0 {
                    return "0"
                }
                
                if d == 1 {
                    if numerator == 1 { return "π" }
                    return "\(Int(numerator))π"
                }
                
                if numerator == 1 {
                    return "π/\(d)"
                }
                
                return "\(Int(numerator))π/\(d)"
            }
        }
        
        return String(format: "%.2fπ", fraction)
    }
    
    // MARK: - Quit
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
