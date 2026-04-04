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
            button.image = AppIcon.logoNSImage()
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
            button.image = AppIcon.logoNSImage()
        case .processing:
            startProcessingAnimation()
        case .success:
            button.image = AppIcon.success.nsImage()
        case .error:
            button.image = AppIcon.error.nsImage()
        case .permissionRequired:
            button.image = AppIcon.warning.nsImage()
        }
    }

    // MARK: - Processing Animation (Bouncing Ball)

    private static let totalFrames = 17
    private static let frameDuration: TimeInterval = 0.05

    private func startProcessingAnimation() {
        guard processingAnimationTimer == nil else { return }
        processingAnimationFrame = 0
        updateProcessingFrame()

        processingAnimationTimer = Timer.scheduledTimer(withTimeInterval: Self.frameDuration, repeats: true) { [weak self] _ in
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
        button.image = Self.bouncingBallFrame(index: processingAnimationFrame)
        processingAnimationFrame = (processingAnimationFrame + 1) % Self.totalFrames
    }

    /// Generates a single frame of the bouncing ball animation as an NSImage.
    /// The animation mirrors the SVG: drop (0.375s), squish (0.05s), bounce up (0.4s).
    private static func bouncingBallFrame(index: Int) -> NSImage {
        // Timeline: 8 frames drop (0.375s), 1 frame squish (0.05s), 8 frames up (0.4s)
        let t = CGFloat(index) / CGFloat(totalFrames)

        let topY: CGFloat = 4.0
        let bottomY: CGFloat = 14.0
        let dropEnd: CGFloat = 8.0 / 17.0   // ~0.47
        let squishEnd: CGFloat = 9.0 / 17.0  // ~0.53

        var cy: CGFloat
        var rx: CGFloat = 3.0
        var ry: CGFloat = 3.0

        if t < dropEnd {
            // Drop phase: ease-in
            let p = t / dropEnd
            let eased = p * p
            cy = topY + (bottomY - topY) * eased
        } else if t < squishEnd {
            // Squish at bottom
            cy = bottomY + 0.5
            rx = 3.6
            ry = 2.25
        } else {
            // Bounce up: ease-out
            let p = (t - squishEnd) / (1.0 - squishEnd)
            let eased = 1.0 - (1.0 - p) * (1.0 - p)
            cy = bottomY - (bottomY - topY) * eased
        }

        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.setFillColor(NSColor.black.cgColor)
            let ellipseRect = CGRect(
                x: rect.midX - rx,
                y: rect.midY - (cy - 9) - ry,
                width: rx * 2,
                height: ry * 2
            )
            ctx.fillEllipse(in: ellipseRect)
            return true
        }
        image.isTemplate = true
        return image
    }
}
