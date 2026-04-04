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

            // Permission banner — shown below header, above divider
            if appState.status == .permissionRequired {
                permissionBanner
            }

            thematicDivider

            if !actions.isEmpty {
                actionListSection
                thematicDivider
            }

            utilitySection

            thematicDivider

            quitSection
        }
        .padding(.vertical, Theme.Spacing.sm)
        .background(Theme.Colors.background)
        .frame(width: 240)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("InDraft")
                .font(Theme.Typography.pageTitle(15))
                .foregroundColor(Theme.Colors.textPrimary)
                .tracking(1.2)

            HStack(spacing: 0) {
                Text(providerDisplayName)
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(Theme.Colors.textTertiary)

                if let model = activeProviders.first?.defaultModel, !model.isEmpty {
                    Text(" \u{00B7} ")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.divider)
                    Text(model)
                        .font(Theme.Typography.mono(9.5))
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                Spacer()

                compactStatusBadge
            }
        }
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.top, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm + 2)
    }

    // MARK: - Permission Banner

    private var permissionBanner: some View {
        Button {
            AccessibilityService.openAccessibilitySettings()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: Theme.Spacing.sm) {
                    Circle()
                        .fill(Theme.Colors.statusAmber)
                        .frame(width: 6, height: 6)

                    Text("Accessibility access required")
                        .font(Theme.Typography.caption(11))
                        .foregroundColor(Theme.Colors.statusAmberText)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }

                Text("Open Settings →")
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(Theme.Colors.statusAmberText)
                    .underline()
                    .padding(.leading, 6 + Theme.Spacing.sm)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.statusAmberBg)
        }
        .buttonStyle(.plain)
    }

    private var providerDisplayName: String {
        if let provider = activeProviders.first {
            return provider.displayName
        }
        return "No provider configured"
    }

    @ViewBuilder
    private var compactStatusBadge: some View {
        switch appState.status {
        case .idle:
            if activeProviders.first?.lastTestStatus == .success {
                HStack(spacing: Theme.Spacing.xs) {
                    Circle()
                        .fill(Theme.Colors.statusGreen)
                        .frame(width: 6, height: 6)
                    Text("ready")
                        .font(Theme.Typography.allCaps(9))
                        .foregroundColor(Theme.Colors.statusGreenText)
                        .tracking(0.5)
                }
            }
        case .permissionRequired:
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
                hotkey: nil
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    SettingsWindowController.shared.showSettings()
                }
            }

            MenuBarRowView(
                icon: "clock.arrow.circlepath",
                title: "History",
                hotkey: nil
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
            hotkey: nil
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
        } else if name.contains("shorten") || name.contains("condense") {
            return "arrow.down.right.and.arrow.up.left"
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
            HStack(spacing: Theme.Spacing.sm + 2) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(isHovered ? Theme.Colors.textPrimary : Theme.Colors.textTertiary)
                    .frame(width: 18, alignment: .center)

                Text(title)
                    .font(Theme.Typography.body(13))
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                if let hotkey = hotkey {
                    Text(hotkey)
                        .font(Theme.Typography.mono(10))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.sm + 1)
                    .fill(isHovered ? Theme.Colors.surfaceContainerHigh.opacity(0.6) : Color.clear)
                    .padding(.horizontal, Theme.Spacing.sm)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(Theme.Motion.quick) {
                isHovered = hovering
            }
            if hovering {
                NSCursor.arrow.push()
            } else {
                NSCursor.pop()
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
