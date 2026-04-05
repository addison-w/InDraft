import SwiftUI
import SwiftData

struct GeneralSettingsView: View {
    @AppStorage(Constants.UserDefaultsKeys.launchAtLogin) private var launchAtLogin = false
    @AppStorage(Constants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = AppearanceMode.system.rawValue
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @Query(sort: \Provider.displayName) private var providers: [Provider]

    @State private var accessibilityGranted = false
    @State private var accessibilityPollTimer: Timer?

    private let launchAtLoginService: LaunchAtLoginServiceProtocol

    init(launchAtLoginService: LaunchAtLoginServiceProtocol = LiveLaunchAtLoginService()) {
        self.launchAtLoginService = launchAtLoginService
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("General")
                    .font(Theme.Typography.pageTitle())
                    .foregroundColor(Theme.Colors.textPrimary)

                // Preferences
                VStack(alignment: .leading, spacing: 0) {
                    settingsRow(
                        title: "Launch at Login",
                        subtitle: "Automatically start InDraft when you log in",
                        isOn: $launchAtLogin
                    )
                    .padding(Theme.Spacing.xl)

                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Appearance
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Appearance")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Choose light, dark, or match system")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        InkSegmentPicker(
                            options: AppearanceMode.allCases.map { ($0.label, $0.rawValue) },
                            selection: $appearanceMode
                        )
                    }
                    .padding(Theme.Spacing.xl)
                }
                .cardStyle()
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        try launchAtLoginService.setEnabled(newValue)
                    } catch {
                        // Revert toggle on failure
                        launchAtLogin = !newValue
                    }
                }

                // Diagnostics section
                Text("DIAGNOSTICS")
                    .font(Theme.Typography.allCaps(10))
                    .foregroundColor(Theme.Colors.textTertiary)
                    .tracking(1)
                    .padding(.top, Theme.Spacing.sm)

                VStack(alignment: .leading, spacing: 0) {
                    // Accessibility
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Accessibility")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("Read and replace selected text")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        if !accessibilityGranted {
                            Button {
                                AccessibilityService.openAccessibilitySettings()
                            } label: {
                                Text("Open Settings")
                                    .font(Theme.Typography.label(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                                    .underline()
                            }
                            .buttonStyle(.plain)
                        }
                        Text(accessibilityGranted ? "granted" : "not granted")
                            .font(Theme.Typography.mono(10))
                            .foregroundColor(accessibilityGranted ? Theme.Colors.statusGreenText : Theme.Colors.error)
                    }
                    .padding(Theme.Spacing.xl)

                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Hotkeys
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Hotkeys")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)

                            if !hotkeyActions.isEmpty {
                                HStack(spacing: Theme.Spacing.sm) {
                                    ForEach(hotkeyActions) { action in
                                        Text(action.hotkeyDisplayString)
                                            .font(Theme.Typography.mono(10))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                            .padding(.horizontal, Theme.Spacing.sm)
                                            .padding(.vertical, 3)
                                            .background(Theme.Colors.surfaceContainerLow)
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                                    }
                                }
                            } else {
                                Text("No hotkeys configured")
                                    .font(Theme.Typography.caption(11))
                                    .foregroundColor(Theme.Colors.textTertiary)
                            }
                        }
                        Spacer()
                        Text("\(hotkeyActions.count) registered")
                            .font(Theme.Typography.mono(10))
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .padding(Theme.Spacing.xl)

                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.xl)

                    // Provider
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Active Provider")
                                .font(Theme.Typography.body(14))
                                .foregroundColor(Theme.Colors.textPrimary)
                            if let active = activeProvider {
                                HStack(spacing: Theme.Spacing.sm) {
                                    Text(active.displayName)
                                        .font(Theme.Typography.mono(10))
                                        .foregroundColor(Theme.Colors.textTertiary)
                                    Text(active.defaultModel)
                                        .font(Theme.Typography.mono(10))
                                        .foregroundColor(Theme.Colors.textTertiary)
                                }
                            }
                        }
                        Spacer()
                        if let active = activeProvider {
                            switch active.lastTestStatus {
                            case .success:
                                Text("connected")
                                    .font(Theme.Typography.mono(10))
                                    .foregroundColor(Theme.Colors.statusGreenText)
                            case .failed:
                                Text("failed")
                                    .font(Theme.Typography.mono(10))
                                    .foregroundColor(Theme.Colors.error)
                            case .untested:
                                Text("untested")
                                    .font(Theme.Typography.mono(10))
                                    .foregroundColor(Theme.Colors.statusAmberText)
                            }
                        } else {
                            Text("none")
                                .font(Theme.Typography.mono(10))
                                .foregroundColor(Theme.Colors.error)
                        }
                    }
                    .padding(Theme.Spacing.xl)
                }
                .cardStyle()

                Spacer()
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .onAppear {
            // Sync toggle with actual system login item status
            launchAtLogin = launchAtLoginService.isEnabled
            checkAccessibility()
            accessibilityPollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                DispatchQueue.main.async {
                    checkAccessibility()
                }
            }
        }
        .onDisappear {
            accessibilityPollTimer?.invalidate()
            accessibilityPollTimer = nil
        }
    }

    // MARK: - Helpers

    private func settingsRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.body(14))
                    .foregroundColor(Theme.Colors.textPrimary)
                Text(subtitle)
                    .font(Theme.Typography.caption(11))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(WabiSabiToggleStyle())
                .labelsHidden()
        }
    }

    private var hotkeyActions: [Action] {
        actions.filter { $0.hasHotkey && $0.enabled }
    }

    private var activeProvider: Provider? {
        providers.first { $0.isActive }
    }

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        accessibilityGranted = AXIsProcessTrustedWithOptions(options)
    }
}
