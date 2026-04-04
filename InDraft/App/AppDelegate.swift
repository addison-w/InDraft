import Cocoa
import SwiftData

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let menuBarController = MenuBarController()
    let appState = AppState()
    let toastManager = ToastManager()
    private var appCoordinator: AppCoordinator?

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

        // Always run as background app (no dock icon)
        NSApp.setActivationPolicy(.accessory)

        // Set up the app coordinator (hotkeys, text transformation, etc.)
        let coordinator = AppCoordinator(appState: appState, toastManager: toastManager)
        coordinator.setup(modelContainer: sharedModelContainer)
        self.appCoordinator = coordinator

        // Configure window controllers
        SettingsWindowController.shared.configure(appState: appState, modelContainer: sharedModelContainer, appCoordinator: coordinator)
        HistoryWindowController.shared.configure(appState: appState, modelContainer: sharedModelContainer)
        OnboardingWindowController.shared.configure(modelContainer: sharedModelContainer)

        // Set up the custom menu bar popover
        menuBarController.setup(
            appState: appState,
            modelContainer: sharedModelContainer,
            appCoordinator: coordinator,
            toastManager: toastManager
        )

        NSLog("[InDraft] Menu bar setup complete")
    }
}
