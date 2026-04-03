## 1. Create ToastManager

- [x] 1.1 Create `InDraft/Services/ToastManager.swift` with `ToastManager` class as `ObservableObject`
- [x] 1.2 Define `ToastItem` model with message, type (success/error/info), and optional dismiss action
- [x] 1.3 Add `@Published var currentToast: ToastItem?` and methods `show(_:)` and `dismiss()`

## 2. Wire AppCoordinator in AppDelegate

- [x] 2.1 Add `AppCoordinator` property to `AppDelegate`
- [x] 2.2 Create `ToastManager` instance in `AppDelegate.applicationDidFinishLaunching`
- [x] 2.3 Create `AppCoordinator` with `appState` and `toastManager` in `AppDelegate.applicationDidFinishLaunching`
- [x] 2.4 Call `appCoordinator.setup(modelContainer:)` after model container creation
- [x] 2.5 Pass `AppCoordinator` reference to `MenuBarController.setup()`

## 3. Update MenuBarController for Coordinator Integration

- [x] 3.1 Add `AppCoordinator` property to `MenuBarController`
- [x] 3.2 Update `setup()` signature to accept `appCoordinator` parameter
- [x] 3.3 Store coordinator reference for access by dropdown view
- [x] 3.4 Add Combine subscription to observe `AppState.status` changes
- [x] 3.5 Call `updateIcon(for:)` when status changes

## 4. Wire Menu Bar Dropdown Actions

- [x] 4.1 Add `appCoordinator` environment object to `MenuBarDropdownView`
- [x] 4.2 Update action row click handler to call `appCoordinator.triggerAction(action)`
- [x] 4.3 Update "Retry Last" click handler to call `appCoordinator.retryLast()`

## 5. Verify Integration

- [ ] 5.1 Build and run the app
- [ ] 5.2 Verify hotkey registration succeeds (no errors in console)
- [ ] 5.3 Test hotkey-triggered transformation (select text, press Ctrl+Opt+1)
- [ ] 5.4 Test menu bar click-triggered transformation
- [ ] 5.5 Verify menu bar icon updates during processing
- [ ] 5.6 Verify toast notifications display correctly
- [ ] 5.7 Test error cases (no text selected, no provider configured)