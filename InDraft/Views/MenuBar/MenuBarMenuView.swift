import SwiftUI
import SwiftData

struct MenuBarMenuView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        // Header info
        Text("OpenAI · gpt-4o")
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

        Button("Retry Last") {
            NSLog("[InDraft] Retry Last tapped")
        }

        Divider()

        Button("Open Settings...") {
            SettingsWindowController.shared.showSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Open History...") {
            NSLog("[InDraft] Open History tapped")
        }
        .keyboardShortcut("h", modifiers: .command)

        Divider()

        Button("Quit InDraft") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
