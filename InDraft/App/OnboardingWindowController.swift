import Cocoa
import SwiftUI
import SwiftData

/// Manages the Onboarding window for first-run setup.
/// Follows the same pattern as SettingsWindowController.
@MainActor
final class OnboardingWindowController {
    static let shared = OnboardingWindowController()

    private var window: NSWindow?
    private var modelContainer: ModelContainer?

    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func showOnboarding() {
        if let window = window {
            window.orderFrontRegardless()
            NSApp.activate()
            return
        }

        // Lazy-configure if not already done
        if modelContainer == nil {
            let schema = Schema([Action.self, Provider.self, HistoryRecord.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try? ModelContainer(for: schema, configurations: [config])
        }

        guard let modelContainer = modelContainer else { return }

        let onboardingView = OnboardingContainerView()
            .modelContainer(modelContainer)
            .modifier(AppearanceModifier())

        let hostingController = NSHostingController(rootView: onboardingView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 600),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "InDraft"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.backgroundColor = NSColor(hex: "FAF9F6")
        window.level = .floating

        self.window = window

        // Prevent macOS from restoring a previous window position
        window.setFrameAutosaveName("")

        window.orderFrontRegardless()
        NSApp.activate()

        // Center after SwiftUI layout pass completes on the next run loop iteration
        DispatchQueue.main.async {
            guard let screen = NSScreen.screens.first else { return }
            let screenFrame = screen.frame
            let windowSize = window.frame.size
            let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
            let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        // Watch for window close
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.window = nil
            }
        }
    }

    func close() {
        window?.close()
        window = nil
    }
}
