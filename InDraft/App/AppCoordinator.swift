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
    private var accessibilityPollTimer: Timer?

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
                guard let self = self, let container = self.modelContainer else { return }
                let freshContext = ModelContext(container)
                self.handleHotkeyPress(actionID: actionID, context: freshContext)
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
            startAccessibilityPolling(context: context)
        }

        // Show onboarding if not complete
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.onboardingComplete) {
            showOnboarding()
        }
    }

    // MARK: - Accessibility Polling

    private func startAccessibilityPolling(context: ModelContext) {
        accessibilityPollTimer?.invalidate()
        accessibilityPollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if AccessibilityService.isAccessibilityGranted {
                    self.accessibilityPollTimer?.invalidate()
                    self.accessibilityPollTimer = nil
                    self.appState.setIdle()
                    self.registerAllHotkeys(context: context)
                }
            }
        }
    }

    deinit {
        accessibilityPollTimer?.invalidate()
    }

    // MARK: - Hotkey Handling

    private func handleHotkeyPress(actionID: UUID, context: ModelContext) {
        // Check accessibility
        guard AccessibilityService.isAccessibilityGranted else {
            toastManager.show(.error("Accessibility required — open Settings to grant"))
            return
        }

        // Find the action
        let predicate = #Predicate<Action> { $0.id == actionID }
        guard let action = try? context.fetch(FetchDescriptor<Action>(predicate: predicate)).first else {
            return
        }

        guard action.enabled else { return }

        // Resolve provider based on action's provider mode
        var resolvedProvider: Provider?

        if action.providerMode == .fixed, let fixedID = action.providerID {
            let fixedPredicate = #Predicate<Provider> { $0.id == fixedID }
            resolvedProvider = try? context.fetch(FetchDescriptor<Provider>(predicate: fixedPredicate)).first

            if resolvedProvider == nil {
                // Fixed provider was deleted — reset action to active mode
                action.providerMode = .active
                action.providerID = nil
                action.modelOverride = nil
                try? context.save()
            }
        }

        if resolvedProvider == nil {
            let activePredicate = #Predicate<Provider> { $0.isActive == true }
            resolvedProvider = try? context.fetch(FetchDescriptor<Provider>(predicate: activePredicate)).first
        }

        guard let provider = resolvedProvider else {
            toastManager.show(.error("No provider configured — check Settings"))
            return
        }

        // Get API key from Keychain
        guard let apiKey = keychainService.retrieve(forReference: provider.apiKeyReference), !apiKey.isEmpty else {
            toastManager.show(.error("API key missing — check Settings"))
            return
        }

        // Execute transformation
        Task {
            guard let transformService = self.transformService else { return }
            let modelToUse = (action.providerMode == .fixed && action.modelOverride?.isEmpty == false) ? action.modelOverride : nil
            let (result, error) = await transformService.execute(action: action, provider: provider, apiKey: apiKey, modelOverride: modelToUse)

            if let error = error {
                switch error {
                case .noTextSelected:
                    toastManager.show(.info("Nothing selected"))
                case .captureFailed(let msg):
                    toastManager.show(.error(msg))
                case .providerFailed(let msg):
                    toastManager.show(.error(msg))
                case .replaceFailed(let msg):
                    toastManager.show(.error(msg))
                case .noActiveProvider:
                    toastManager.show(.error("No provider configured — check Settings"))
                case .actionDisabled:
                    break
                }
            } else if let result = result {
                switch result {
                case .replaced, .fallbackClipboard:
                    toastManager.show(.success("Replaced", actionName: action.name))
                case .copiedToClipboard:
                    toastManager.show(.success("Copied — paste manually", actionName: action.name))
                case .previewing(let original, let transformed):
                    showPreview(original: original, transformed: transformed, actionName: action.name)
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

    // MARK: - Hotkey Registration

    /// Re-register all hotkeys from current database state.
    /// Call this after any action mutation (create, delete, edit hotkey, toggle enable).
    func refreshHotkeys() {
        guard let modelContainer = modelContainer else { return }
        let context = modelContainer.mainContext
        try? context.save()
        registerAllHotkeys(context: context)
    }

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

    private func showPreview(original: String, transformed: String, actionName: String) {
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
                        switch result {
                        case .copiedToClipboard:
                            self?.toastManager.show(.success("Copied — paste manually", actionName: actionName))
                        default:
                            self?.toastManager.show(.success("Replaced", actionName: actionName))
                        }
                    }
                }
            },
            onReject: { /* panel dismissed, no action */ },
            onCopy: { [weak self] in
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(transformed, forType: .string)
                self?.toastManager.show(.success("Copied", actionName: actionName))
            }
        )
    }

    // MARK: - Onboarding

    private func showOnboarding() {
        OnboardingWindowController.shared.showOnboarding()
    }
}
