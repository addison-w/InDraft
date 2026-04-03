import SwiftUI
import SwiftData

struct DiagnosticsSettingsView: View {
    @Query(sort: \Action.sortOrder) private var actions: [Action]
    @Query(sort: \Provider.displayName) private var providers: [Provider]

    @State private var accessibilityGranted = false
    @State private var isTesting = false
    @State private var providerLatency: TimeInterval?
    @State private var accessibilityPollTimer: Timer?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                Text("Diagnostics")
                    .font(Theme.Typography.pageTitle())
                    .foregroundColor(Theme.Colors.textPrimary)

                Text("Verify system permissions and check connection stability across your local and cloud providers.")
                    .font(Theme.Typography.body(13))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Accessibility
                diagnosticCard {
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Accessibility")
                                .font(Theme.Typography.body(15))
                                .fontWeight(.medium)
                                .foregroundColor(Theme.Colors.textPrimary)
                            Text("InDraft can read and replace selected text")
                                .font(Theme.Typography.caption(11))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        if !accessibilityGranted {
                            Button("Open System Settings") {
                                AccessibilityService.openAccessibilitySettings()
                            }
                            .font(Theme.Typography.caption(11))
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        StatusPill(
                            text: accessibilityGranted ? "GRANTED" : "NOT GRANTED",
                            color: accessibilityGranted ? Theme.Colors.statusGreen : Theme.Colors.error
                        )
                    }
                }

                // Hotkey Registration
                diagnosticCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("Hotkey Registration")
                                    .font(Theme.Typography.body(15))
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.textPrimary)
                                Text("Global shortcut listener status")
                                    .font(Theme.Typography.caption(11))
                                    .foregroundColor(Theme.Colors.textSecondary)
                            }
                            Spacer()
                            StatusPill(
                                text: "\(hotkeyActions.count) OF \(hotkeyActions.count) REGISTERED",
                                color: Theme.Colors.statusBlue
                            )
                        }

                        if !hotkeyActions.isEmpty {
                            HStack(spacing: Theme.Spacing.sm) {
                                ForEach(hotkeyActions) { action in
                                    HStack(spacing: Theme.Spacing.xs) {
                                        Circle()
                                            .fill(action.enabled ? Theme.Colors.accent : Theme.Colors.textTertiary)
                                            .frame(width: 6, height: 6)
                                        Text(action.hotkeyDisplayString)
                                            .font(Theme.Typography.mono(10))
                                            .foregroundColor(Theme.Colors.textSecondary)
                                    }
                                    .badgeStyle()
                                }
                            }
                        }
                    }
                }

                // Provider Connectivity
                diagnosticCard {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                Text("Provider Connectivity")
                                    .font(Theme.Typography.body(15))
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                            Spacer()
                            if let active = activeProvider {
                                StatusPill(
                                    text: active.lastTestStatus == .success ? "CONNECTED" : "UNTESTED",
                                    color: active.lastTestStatus == .success ? Theme.Colors.statusGreen : Theme.Colors.statusAmber
                                )
                            } else {
                                StatusPill(text: "NO PROVIDER", color: Theme.Colors.error)
                            }
                        }

                        if let active = activeProvider {
                            HStack(spacing: Theme.Spacing.md) {
                                providerDetail(label: active.displayName)
                                providerDetail(label: active.defaultModel)
                                if let latency = providerLatency {
                                    providerDetail(label: String(format: "%.0fms", latency * 1000))
                                }
                            }
                        }
                    }
                }

                // Test Now button
                HStack {
                    Spacer()
                    Button {
                        runDiagnostics()
                    } label: {
                        HStack(spacing: Theme.Spacing.xs) {
                            if isTesting {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text("Test Now")
                                .font(Theme.Typography.body(13))
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(isTesting)
                    Spacer()
                }

                Spacer()
            }
            .padding(Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
        .onAppear {
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

    // MARK: - Subviews

    private func diagnosticCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(Theme.Spacing.xl)
            .cardStyle()
    }

    private func providerDetail(label: String) -> some View {
        Text(label)
            .font(Theme.Typography.mono(10))
            .foregroundColor(Theme.Colors.textSecondary)
            .badgeStyle()
    }

    // MARK: - Computed

    private var hotkeyActions: [Action] {
        actions.filter { $0.hasHotkey && $0.enabled }
    }

    private var activeProvider: Provider? {
        providers.first { $0.isActive }
    }

    // MARK: - Actions

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false] as CFDictionary
        accessibilityGranted = AXIsProcessTrustedWithOptions(options)
    }

    private func runDiagnostics() {
        isTesting = true
        checkAccessibility()

        Task {
            guard let active = activeProvider else {
                await MainActor.run { isTesting = false }
                return
            }

            // Resolve API key from Keychain
            let keychain = LiveKeychainService()
            let apiKey = keychain.retrieve(forReference: active.apiKeyReference) ?? ""

            let service = LiveProviderService()
            let result = await service.testConnection(
                baseURL: active.baseURL,
                apiKey: apiKey,
                model: active.defaultModel,
                timeout: TimeInterval(active.timeoutSeconds)
            )

            await MainActor.run {
                switch result {
                case .success(_, let latencyMs):
                    providerLatency = Double(latencyMs) / 1000.0
                    active.lastTestStatus = .success
                    active.lastTestedAt = Date()
                    active.lastTestError = nil
                case .failure(let message):
                    providerLatency = nil
                    active.lastTestStatus = .failed
                    active.lastTestError = message
                }
                active.updatedAt = Date()
                isTesting = false
            }
        }
    }
}
