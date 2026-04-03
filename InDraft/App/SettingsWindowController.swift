import Cocoa
import SwiftUI
import SwiftData

/// Manages the Settings window for the menu bar app.
/// Uses orderFrontRegardless() to reliably bring window to front
/// without changing activation policy (app stays as LSUIElement).
@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var window: NSWindow?
    private var appState: AppState?
    private var modelContainer: ModelContainer?

    func configure(appState: AppState, modelContainer: ModelContainer) {
        self.appState = appState
        self.modelContainer = modelContainer
    }

    func showSettings() {
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
        if appState == nil {
            appState = AppState()
        }

        guard let appState = appState, let modelContainer = modelContainer else { return }

        let settingsView = SettingsView()
            .environmentObject(appState)
            .modelContainer(modelContainer)

        let hostingController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "InDraft Settings"
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("InDraftSettings")

        self.window = window

        window.orderFrontRegardless()
        NSApp.activate()

        // Watch for window close to clean up reference
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
}
