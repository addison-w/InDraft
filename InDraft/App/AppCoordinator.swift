import Cocoa
import SwiftData

/// Coordinates hotkey triggers → TransformService pipeline → status feedback → history recording.
/// Also wires menu bar dropdown actions to the same pipeline.
@MainActor
final class AppCoordinator: ObservableObject {
    let appState: AppState
    let toastManager: ToastManager

    private var hotkeyService: LiveHotkeyService?
    private var transformService: LiveTransformService?
    private var historyService: LiveHistoryService?
    private var keychainService: LiveKeychainService
    private var modelContainer: ModelContainer?
    private var previewController: PreviewPanelController?

    init(appState: AppState, toastManager: ToastManager) {
        self.appState = appState
        self.toastManager = toastManager
        self.keychainService = LiveKeychainService()
    }

    func setup(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)

        // Seed default actions on first launch
        SeedData.createDefaultActions(in: context)

        // Set up services
        let captureService = LiveTextCaptureService()
        let replaceService = LiveTextReplaceService()
        let providerService = LiveProviderService()
        self.historyService = LiveHistoryService(modelContext: context)

        self.transformService = LiveTransformService(
            captureService: captureService,
            replaceService: replaceService,
            providerService: providerService,
            historyService: historyService,
            appState: appState
        )

        // Set up hotkeys
        let hotkeyService = LiveHotkeyService()
        self.hotkeyService = hotkeyService
        hotkeyService.onHotkeyPressed = { [weak self] actionID in
            Task { @MainActor in
                self?.handleHotkeyPress(actionID: actionID, context: context)
            }
        }

        // Register hotkeys for all enabled actions
        registerAllHotkeys(context: context)

        // Prune old history records
        let retentionDays = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.historyRetentionDays)
        if retentionDays > 0 {
            historyService?.pruneOldRecords(retentionDays: retentionDays)
        }

        // Check accessibility permission
        if !AccessibilityService.isAccessibilityGranted {
            appState.setPermissionRequired()
        }

        // Show onboarding if not complete
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.onboardingComplete) {
            showOnboarding()
        }
    }

    // MARK: - Hotkey Handling

    private func handleHotkeyPress(actionID: UUID, context: ModelContext) {
        // Check accessibility
        guard AccessibilityService.isAccessibilityGranted else {
            toastManager.show(.error("Accessibility permission required — check Settings > Diagnostics"))
            return
        }

        // Find the action
        let predicate = #Predicate<Action> { $0.id == actionID }
        guard let action = try? context.fetch(FetchDescriptor<Action>(predicate: predicate)).first else {
            return
        }

        guard action.enabled else { return }

        // Find the provider
        let provider: Provider?
        if action.providerMode == .fixed, let providerID = action.providerID {
            let provPredicate = #Predicate<Provider> { $0.id == providerID }
            provider = try? context.fetch(FetchDescriptor<Provider>(predicate: provPredicate)).first
        } else {
            let activePredicate = #Predicate<Provider> { $0.isActive == true }
            provider = try? context.fetch(FetchDescriptor<Provider>(predicate: activePredicate)).first
        }

        guard let provider = provider else {
            toastManager.show(.error("No active provider — configure one in Settings > Providers"))
            return
        }

        // Get API key from Keychain
        guard let apiKey = keychainService.retrieve(forReference: provider.apiKeyReference), !apiKey.isEmpty else {
            toastManager.show(.error("API key not found — check Settings > Providers"))
            return
        }

        // Execute transformation
        Task {
            guard let transformService = self.transformService else { return }
            let (result, error) = await transformService.execute(action: action, provider: provider, apiKey: apiKey)

            if let error = error {
                switch error {
                case .noTextSelected:
                    toastManager.show(.info("No text selected"))
                case .captureFailed(let msg):
                    toastManager.show(.error(msg))
                case .providerFailed(let msg):
                    toastManager.show(.error(msg))
                case .replaceFailed(let msg):
                    toastManager.show(.error(msg))
                case .noActiveProvider:
                    toastManager.show(.error("No active provider — configure one in Settings > Providers"))
                case .actionDisabled:
                    break
                }
            } else if let result = result {
                switch result {
                case .replaced:
                    toastManager.show(.success("Text replaced"))
                case .fallbackClipboard:
                    toastManager.show(.info("Result copied to clipboard — paste manually"))
                case .copiedToClipboard:
                    toastManager.show(.success("Result copied to clipboard"))
                case .previewing(let original, let transformed):
                    showPreview(original: original, transformed: transformed)
                }
            }
        }
    }

    // MARK: - Menu Bar Action Trigger

    func triggerAction(_ action: Action) {
        guard let modelContainer = modelContainer else { return }
        let context = ModelContext(modelContainer)
        handleHotkeyPress(actionID: action.id, context: context)
    }

    // MARK: - Retry Last

    func retryLast() {
        guard let modelContainer = modelContainer else { return }
        let context = ModelContext(modelContainer)

        guard let lastRecord = historyService?.mostRecentRecord() else {
            toastManager.show(.info("No previous transformation"))
            return
        }

        // Find the action or use the snapshot data
        if let actionID = lastRecord.actionID {
            handleHotkeyPress(actionID: actionID, context: context)
        }
    }

    // MARK: - Hotkey Registration

    func registerAllHotkeys(context: ModelContext) {
        hotkeyService?.deregisterAll()

        let actions = (try? context.fetch(FetchDescriptor<Action>())) ?? []
        for action in actions where action.enabled && action.hasHotkey {
            if let keyCode = action.hotkeyKeyCode, let modifiers = action.hotkeyModifiers {
                try? hotkeyService?.register(keyCode: keyCode, modifiers: modifiers, actionID: action.id)
            }
        }
    }

    // MARK: - Preview

    private func showPreview(original: String, transformed: String) {
        if previewController == nil {
            previewController = PreviewPanelController()
        }
        previewController?.show(
            original: original,
            transformed: transformed,
            onAccept: { [weak self] in
                // Replace the selected text with transformed text
                Task {
                    let replaceService = LiveTextReplaceService()
                    let result = try? await replaceService.replaceSelectedText(with: transformed)
                    await MainActor.run {
                        if case .copiedToClipboard = result {
                            self?.toastManager.show(.info("Result copied to clipboard — paste manually"))
                        } else {
                            self?.toastManager.show(.success("Text replaced"))
                        }
                    }
                }
            },
            onReject: { /* panel dismissed, no action */ },
            onCopy: { [weak self] in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(transformed, forType: .string)
                self?.toastManager.show(.success("Copied to clipboard"))
            }
        )
    }

    // MARK: - Onboarding

    private func showOnboarding() {
        // Onboarding window will be presented by the SwiftUI scene
    }
}
