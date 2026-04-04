import Cocoa

enum AccessibilityService {
    /// Check if the app has Accessibility permission
    static var isAccessibilityGranted: Bool {
        AXIsProcessTrusted()
    }

    /// Check with prompt — shows the system dialog if not trusted
    static func checkWithPrompt() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Open System Settings to the Accessibility pane
    static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
