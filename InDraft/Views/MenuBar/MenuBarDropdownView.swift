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
            headerSection

            thematicDivider

            if !actions.isEmpty {
                actionListSection
                thematicDivider
            }

            utilitySection

            thematicDivider

            quitSection
        }
        .padding(.vertical, Theme.Spacing.xs + 2)
        .background(Theme.Colors.background)
        .frame(width: 248)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text("INDRAFT")
                    .font(Theme.Typography.allCaps(10))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .tracking(1.5)
                Spacer()
                statusBadge
            }

            HStack(spacing: Theme.Spacing.xs) {
                Text(providerDisplayName)
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(.horizontal, Theme.Spacing.md + 2)
        .padding(.vertical, Theme.Spacing.sm + 2)
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
            ProcessingBadge()
        case .success:
            Text("done")
                .badgeStyle(color: Theme.Colors.statusGreenBg)
                .foregroundColor(Theme.Colors.statusGreenText)
        case .error:
            Text("error")
                .badgeStyle(color: Theme.Colors.statusRedBg)
                .foregroundColor(Theme.Colors.statusRed)
        case .permissionRequired:
            HStack(spacing: Theme.Spacing.sm) {
                Text("needs access")
                    .badgeStyle(color: Theme.Colors.statusAmberBg)
                    .foregroundColor(Theme.Colors.statusAmberText)
                Button("Open Settings") {
                    AccessibilityService.openAccessibilitySettings()
                }
                .font(Theme.Typography.caption(11))
                .buttonStyle(.plain)
                .foregroundColor(Theme.Colors.statusAmberText)
                .underline()
            }
        }
    }

    // MARK: - Action List

    private var actionListSection: some View {
        ForEach(actions.filter { $0.enabled }) { action in
            MenuBarRowView(
                icon: iconForAction(action),
                title: action.name,
                hotkey: action.hasHotkey ? action.hotkeyDisplayString : nil
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
            .fill(Theme.Colors.divider)
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
                    .foregroundColor(isHovered ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                    .frame(width: 16, alignment: .center)

                Text(title)
                    .font(Theme.Typography.body(13))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                if let hotkey = hotkey {
                    Text(hotkey)
                        .font(Theme.Typography.mono(10))
                        .foregroundColor(Theme.Colors.textTertiary)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Theme.Colors.badgeBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                }
            }
            .padding(.horizontal, Theme.Spacing.md + 2)
            .padding(.vertical, Theme.Spacing.sm)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                    .fill(isHovered ? Theme.Colors.surfaceContainerLow : Color.clear)
                    .padding(.horizontal, Theme.Spacing.xs)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(Theme.Motion.quick) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Processing Badge

struct ProcessingBadge: View {
    @State private var isPulsing = false

    var body: some View {
        Text("processing")
            .badgeStyle(color: Theme.Colors.badgeBackground)
            .foregroundColor(Theme.Colors.textSecondary)
            .opacity(isPulsing ? 0.5 : 1.0)
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
