import Cocoa
import SwiftUI
import SwiftData

/// Manages the History window for the menu bar app.
/// Uses the same singleton pattern as SettingsWindowController.
@MainActor
final class HistoryWindowController {
    static let shared = HistoryWindowController()

    private var window: NSWindow?
    private var appState: AppState?
    private var modelContainer: ModelContainer?

    private init() {}

    func configure(appState: AppState, modelContainer: ModelContainer) {
        self.appState = appState
        self.modelContainer = modelContainer
    }

    func showHistory() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
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

        let historyView = HistoryWindowView()
            .environmentObject(appState)
            .modelContainer(modelContainer)

        let hostingController = NSHostingController(rootView: historyView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 650, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "InDraft History"
        newWindow.contentViewController = hostingController
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.setFrameAutosaveName("InDraftHistory")

        self.window = newWindow

        // Temporarily become regular app to show in dock/cmd-tab
        NSApp.setActivationPolicy(.regular)
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate()

        // Watch for window close to revert activation policy
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: newWindow,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                if !UserDefaults.standard.bool(forKey: "showDockIcon") {
                    NSApp.setActivationPolicy(.accessory)
                }
                self?.window = nil
            }
        }
    }
}