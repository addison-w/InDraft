import SwiftUI
import SwiftData

@main
struct InDraftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.appState)
                .modelContainer(appDelegate.sharedModelContainer)
        }
    }
}
