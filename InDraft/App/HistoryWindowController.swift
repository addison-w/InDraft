import Cocoa
import SwiftUI
import SwiftData

/// Manages the History window for the menu bar app.
/// Uses orderFrontRegardless() to reliably bring window to front
/// without changing activation policy (app stays as LSUIElement).
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

        let historyView = HistoryWindowView()
            .environmentObject(appState)
            .modelContainer(modelContainer)

        let hostingController = NSHostingController(rootView: historyView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 520),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "InDraft History"
        newWindow.titlebarAppearsTransparent = true
        newWindow.titleVisibility = .hidden
        // Hide native traffic light — custom close button in titlebar
        newWindow.standardWindowButton(.closeButton)?.isHidden = true
        newWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        newWindow.standardWindowButton(.zoomButton)?.isHidden = true
        newWindow.contentViewController = hostingController
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.hidesOnDeactivate = false
        newWindow.setFrameAutosaveName("InDraftHistory")
        newWindow.level = .floating

        self.window = newWindow

        newWindow.orderFrontRegardless()
        NSApp.activate()

        // Watch for window close to clean up reference
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: newWindow,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.window = nil
            }
        }
    }
}
