import Cocoa
import SwiftUI
import SwiftData
import Combine

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
    private var appCoordinator: AppCoordinator?
    private var statusCancellable: AnyCancellable?
    private var toastOverlay: ToastOverlayController?
    private var processingAnimationTimer: Timer?
    private var processingAnimationFrame: Int = 0

    func setup(appState: AppState, modelContainer: ModelContainer, appCoordinator: AppCoordinator, toastManager: ToastManager) {
        NSLog("[InDraft] MenuBarController.setup called")
        self.appState = appState
        self.modelContainer = modelContainer
        self.appCoordinator = appCoordinator

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

        let dropdownView = MenuBarDropdownView(coordinator: appCoordinator)
            .environmentObject(appState)
            .modelContainer(modelContainer)

        popover.contentViewController = NSHostingController(rootView: dropdownView)
        self.popover = popover

        // Seed default actions
        SeedData.createDefaultActions(in: modelContainer.mainContext)

        // Configure settings window controller
        SettingsWindowController.shared.configure(
            appState: appState,
            modelContainer: modelContainer,
            appCoordinator: appCoordinator
        )

        // Observe status changes to update the menu bar icon
        statusCancellable = appState.$status.sink { [weak self] status in
            self?.updateIcon(for: status)
        }

        // Set up toast overlay near the status item
        self.toastOverlay = ToastOverlayController(toastManager: toastManager, statusItem: statusItem)
    }

    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        // Remove any existing event monitor first to prevent it from
        // interfering with this click (the monitor would otherwise catch
        // the status bar button click as an "outside" click, closing the
        // popover before this toggle can process it).
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }

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

        // Stop any running animation when leaving processing state
        if status != .processing {
            stopProcessingAnimation()
        }

        switch status {
        case .idle:
            button.image = NSImage(systemSymbolName: "pencil.line", accessibilityDescription: "InDraft")
        case .processing:
            startProcessingAnimation()
        case .success:
            button.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "Success")
        case .error:
            button.image = NSImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: "Error")
        case .permissionRequired:
            button.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Permission Required")
        }
    }

    // MARK: - Processing Animation

    private func startProcessingAnimation() {
        guard processingAnimationTimer == nil else { return }
        processingAnimationFrame = 0
        updateProcessingFrame()

        processingAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProcessingFrame()
            }
        }
    }

    private func stopProcessingAnimation() {
        processingAnimationTimer?.invalidate()
        processingAnimationTimer = nil
        processingAnimationFrame = 0
    }

    private func updateProcessingFrame() {
        guard let button = statusItem?.button else { return }
        let angles: [CGFloat] = [0, 120, 240]
        let angle = angles[processingAnimationFrame % angles.count]
        button.image = Self.rotatedSymbol(
            name: "arrow.trianglehead.2.counterclockwise",
            degrees: angle,
            accessibilityDescription: "Processing"
        )
        processingAnimationFrame += 1
    }

    static func rotatedSymbol(name: String, degrees: CGFloat, accessibilityDescription: String) -> NSImage? {
        guard let original = NSImage(systemSymbolName: name, accessibilityDescription: accessibilityDescription) else {
            return nil
        }

        let size = original.size
        let radians = degrees * .pi / 180

        let newImage = NSImage(size: size)
        newImage.lockFocus()
        let transform = NSAffineTransform()
        transform.translateX(by: size.width / 2, yBy: size.height / 2)
        transform.rotate(byRadians: radians)
        transform.translateX(by: -size.width / 2, yBy: -size.height / 2)
        transform.concat()
        original.draw(in: NSRect(origin: .zero, size: size))
        newImage.unlockFocus()
        newImage.isTemplate = true

        return newImage
    }
}
