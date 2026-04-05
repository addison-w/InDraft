import SwiftUI
import SwiftData
import Hugeicons

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
            HStack {
                Text("InDraft")
                    .font(Theme.Typography.pageTitle(15))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .tracking(1.2)

                Spacer()

                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Text("v\(version)")
                        .font(Theme.Typography.mono(9))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
            }

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
                icon: .settings,
                title: "Settings",
                hotkey: nil
            ) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    SettingsWindowController.shared.showSettings()
                }
            }

            MenuBarRowView(
                icon: .clockRewind,
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
            icon: .power,
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

    private func iconForAction(_ action: Action) -> AppIcon {
        let name = action.name.lowercased()

        // Existing matches (most specific first)
        if name.contains("rewrite") || name.contains("write") {
            return .edit
        } else if name.contains("grammar") || name.contains("fix") {
            return .grammarCheck
        } else if name.contains("shorten") || name.contains("condense") {
            return .shorten
        } else if name.contains("paraphrase") || name.contains("rephrase") {
            return .paraphrase
        } else if name.contains("summarize") || name.contains("summary") {
            return .summarize
        } else if name.contains("translate") {
            return .translate
        }

        // Professional / business
        else if name.contains("professional") || name.contains("business") || name.contains("corporate") || name.contains("executive") {
            return .professional
        }
        // ELI5 / simplify
        else if name.contains("eli5") || name.contains("simplify") || name.contains("simple") || name.contains("easy") || name.contains("beginner") || name.contains("basics") {
            return .simplify
        }
        // Expand / elaborate
        else if name.contains("expand") || name.contains("elaborate") || name.contains("extend") || name.contains("lengthen") || name.contains("detail") || name.contains("longer") {
            return .expand
        }
        // Email / message
        else if name.contains("email") || name.contains("mail") || name.contains("letter") || name.contains("memo") {
            return .email
        }
        // Chat / conversation
        else if name.contains("chat") || name.contains("conversation") || name.contains("dialogue") || name.contains("reply") || name.contains("respond") {
            return .chat
        }
        // Code / technical
        else if name.contains("code") || name.contains("program") || name.contains("technical") || name.contains("developer") || name.contains("debug") || name.contains("script") {
            return .code
        }
        // Creative / brainstorm
        else if name.contains("creative") || name.contains("brainstorm") || name.contains("idea") || name.contains("inspire") || name.contains("imagine") {
            return .creative
        }
        // Formal / academic
        else if name.contains("formal") || name.contains("academic") || name.contains("scholarly") || name.contains("essay") || name.contains("thesis") || name.contains("research") {
            return .formal
        }
        // Casual / friendly
        else if name.contains("casual") || name.contains("friendly") || name.contains("relaxed") || name.contains("informal") || name.contains("chill") {
            return .casual
        }
        // List / organize
        else if name.contains("list") || name.contains("bullet") || name.contains("outline") || name.contains("organize") || name.contains("structure") {
            return .list
        }
        // Heading / title
        else if name.contains("heading") || name.contains("title") || name.contains("headline") || name.contains("caption") {
            return .heading
        }
        // Hashtag / tag
        else if name.contains("hashtag") || name.contains("tag") || name.contains("keyword") || name.contains("seo") {
            return .hashtag
        }
        // Tone / sentiment
        else if name.contains("tone") || name.contains("mood") || name.contains("sentiment") || name.contains("emotion") || name.contains("feel") {
            return .tone
        }
        // Magic / transform
        else if name.contains("magic") || name.contains("transform") || name.contains("convert") || name.contains("auto") {
            return .magic
        }

        else {
            return .textDefault
        }
    }

}

// MARK: - Menu Bar Row View

struct MenuBarRowView: View {
    let icon: AppIcon
    let title: String
    let hotkey: String?
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: Theme.Spacing.sm + 2) {
                icon.image()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
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
