import SwiftUI
import SwiftData

struct MenuBarDropdownView: View {
    @EnvironmentObject var appState: AppState
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @Query(filter: #Predicate<Provider> { $0.isActive == true }) private var activeProviders: [Provider]
    @Environment(\.dismiss) private var dismiss

    let coordinator: AppCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header
            headerSection

            thematicDivider

            // MARK: - Action List
            if !actions.isEmpty {
                actionListSection
                thematicDivider
            }

            // MARK: - Utility Items
            utilitySection

            thematicDivider

            // MARK: - Quit
            quitSection
        }
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .frame(width: 260)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                Text("INDRAFT")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .tracking(1.5)
                Spacer()
                statusBadge
            }

            HStack(spacing: Theme.Spacing.xs) {
                Text("PROVIDER")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(0.8)
                Text(providerDisplayName)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.Colors.textSecondary)
                Text("▾")
                    .font(.system(size: 9))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.md)
    }

    private var providerDisplayName: String {
        if let provider = activeProviders.first {
            return provider.displayName
        }
        return "No provider configured"
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch appState.status {
        case .idle:
            EmptyView()
        case .processing:
            Text("processing")
                .badgeStyle(color: Theme.Colors.badgeBackground)
                .foregroundColor(Theme.Colors.textSecondary)
        case .success:
            Text("done")
                .badgeStyle(color: Color(hex: "EDF3EC"))
                .foregroundColor(Color(hex: "346538"))
        case .error:
            Text("error")
                .badgeStyle(color: Color(hex: "FDEBEC"))
                .foregroundColor(Color(hex: "9F2F2D"))
        case .permissionRequired:
            Text("needs access")
                .badgeStyle(color: Color(hex: "FBF3DB"))
                .foregroundColor(Color(hex: "956400"))
        }
    }

    // MARK: - Action List

    private var actionListSection: some View {
        ForEach(actions) { action in
            MenuBarRowView(
                icon: iconForAction(action),
                title: action.name,
                hotkey: action.hasHotkey ? hotkeyBadgeText(action) : nil
            ) {
                dismiss()
                coordinator.triggerAction(action)
            }
        }
    }

    // MARK: - Utility Items

    private var utilitySection: some View {
        Group {
            MenuBarRowView(
                icon: "gearshape",
                title: "Settings",
                hotkey: "⌘,"
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    SettingsWindowController.shared.showSettings()
                }
            }

            MenuBarRowView(
                icon: "clock.arrow.circlepath",
                title: "History",
                hotkey: "⌘H"
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    HistoryWindowController.shared.showHistory()
                }
            }
        }
    }

    // MARK: - Quit

    private var quitSection: some View {
        MenuBarRowView(
            icon: "power",
            title: "Quit InDraft",
            hotkey: "⌘Q"
        ) {
            NSApplication.shared.terminate(nil)
        }
    }

    // MARK: - Helpers

    private var thematicDivider: some View {
        Rectangle()
            .fill(Color(hex: "AFB3AE").opacity(0.15))
            .frame(height: 1)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
    }

    private func iconForAction(_ action: Action) -> String {
        let name = action.name.lowercased()
        if name.contains("rewrite") || name.contains("write") {
            return "pencil.line"
        } else if name.contains("grammar") || name.contains("fix") {
            return "checkmark.circle"
        } else if name.contains("paraphrase") || name.contains("rephrase") {
            return "arrow.2.squarepath"
        } else if name.contains("summarize") || name.contains("summary") {
            return "doc.text"
        } else if name.contains("translate") {
            return "globe"
        } else {
            return "text.alignleft"
        }
    }

    private func hotkeyBadgeText(_ action: Action) -> String {
        guard let keyCode = action.hotkeyKeyCode else { return "" }
        return "⌃\(KeyCodeMapping.stringForKeyCode(keyCode))"
    }
}

// MARK: - Menu Bar Row View

struct MenuBarRowView: View {
    let icon: String
    let title: String
    let hotkey: String?
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(width: 16, alignment: .center)

                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                if let hotkey = hotkey {
                    Text(hotkey)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Theme.Colors.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.badgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .background(isHovered ? Theme.Colors.surfaceContainerLow : Color.clear)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
