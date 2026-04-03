import SwiftUI
import SwiftData

struct MenuBarMenuView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @Query(filter: #Predicate<Provider> { $0.isActive == true }) private var activeProviders: [Provider]
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        // Header info
        Text(providerDisplayName)
            .font(.caption)

        Divider()

        // Actions
        ForEach(actions) { action in
            Button {
                NSLog("[InDraft] Action tapped: \(action.name)")
            } label: {
                HStack {
                    Text(action.name)
                    if action.hasHotkey {
                        Spacer()
                        Text(action.hotkeyDisplayString)
                    }
                }
            }
        }

        Divider()

        Button("Settings") {
            SettingsWindowController.shared.showSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("History") {
            HistoryWindowController.shared.showHistory()
        }
        .keyboardShortcut("h", modifiers: .command)

        Divider()

        Button("Quit InDraft") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }

    private var providerDisplayName: String {
        if let provider = activeProviders.first {
            return provider.displayName
        }
        return "No provider configured"
    }
}
