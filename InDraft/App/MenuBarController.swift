import Cocoa
import SwiftUI
import SwiftData

/// Manages the menu bar status item and custom popover dropdown.
/// Uses NSStatusItem + NSPopover instead of SwiftUI MenuBarExtra
/// for full control over the dropdown appearance and click behavior.
@MainActor
final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?
    private var appState: AppState?
    private var modelContainer: ModelContainer?

    func setup(appState: AppState, modelContainer: ModelContainer) {
        NSLog("[InDraft] MenuBarController.setup called")
        self.appState = appState
        self.modelContainer = modelContainer

        // Create status item
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "pencil.line", accessibilityDescription: "InDraft")
            button.action = #selector(togglePopover)
            button.target = self
        }
        self.statusItem = statusItem

        // Create popover
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.animates = true
        popover.contentSize = NSSize(width: 260, height: 340)

        let dropdownView = MenuBarDropdownView()
            .environmentObject(appState)
            .modelContainer(modelContainer)

        popover.contentViewController = NSHostingController(rootView: dropdownView)
        self.popover = popover

        // Seed default actions
        SeedData.createDefaultActions(in: modelContainer.mainContext)

        // Configure settings window controller
        SettingsWindowController.shared.configure(
            appState: appState,
            modelContainer: modelContainer
        )
    }

    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Close popover when clicking outside
            eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                self?.closePopover()
            }
        }
    }

    func closePopover() {
        popover?.performClose(nil)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func updateIcon(for status: AppStatus) {
        guard let button = statusItem?.button else { return }
        switch status {
        case .idle:
            button.image = NSImage(systemSymbolName: "pencil.line", accessibilityDescription: "InDraft")
        case .processing:
            button.image = NSImage(systemSymbolName: "arrow.trianglehead.2.counterclockwise", accessibilityDescription: "Processing")
        case .success:
            button.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "Success")
        case .error:
            button.image = NSImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: "Error")
        case .permissionRequired:
            button.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Permission Required")
        }
    }
}
