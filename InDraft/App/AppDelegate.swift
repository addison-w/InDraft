import Cocoa
import SwiftData

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let menuBarController = MenuBarController()
    let appState = AppState()

    lazy var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Action.self,
            Provider.self,
            HistoryRecord.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // App launched

        // Run as background app
        if !UserDefaults.standard.bool(forKey: "showDockIcon") {
            NSApp.setActivationPolicy(.accessory)
        }

        // Set up the custom menu bar popover
        menuBarController.setup(
            appState: appState,
            modelContainer: sharedModelContainer
        )

        NSLog("[InDraft] Menu bar setup complete")
    }
}
