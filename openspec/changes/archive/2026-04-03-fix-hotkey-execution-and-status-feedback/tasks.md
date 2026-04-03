## 1. Consolidate Toast Infrastructure

- [x] 1.1 Delete `InDraft/Services/ToastManager.swift` (the duplicate with `ToastItem` + simple `ToastType` enum)
- [x] 1.2 Verify `InDraft/Views/MenuBar/ToastView.swift` is the canonical implementation with `ToastType` (associated String values) and `ToastManager` class
- [x] 1.3 Build the project and confirm no compilation errors from the type consolidation

## 2. Create Toast Overlay Controller

- [x] 2.1 Create `InDraft/Views/MenuBar/ToastOverlayController.swift` with a borderless, non-activating `NSPanel` that hosts `ToastView` via `NSHostingView`
- [x] 2.2 Configure `NSPanel` with `.nonactivatingPanel` style mask and `NSWindow.Level.statusBar` window level
- [x] 2.3 Add Combine subscription to `ToastManager.currentToast` — show panel on non-nil, hide on nil
- [x] 2.4 Implement fade-in (0.2s) and fade-out (0.15s) animations using `NSAnimationContext`
- [x] 2.5 Position the panel below the menu bar status item button (8pt offset) using `statusItem.button.window.frame`
- [x] 2.6 Add click-to-dismiss gesture on the toast panel

## 3. Wire Toast Overlay into App

- [x] 3.1 Add `ToastOverlayController` as a property on `MenuBarController`
- [x] 3.2 Initialize `ToastOverlayController` in `MenuBarController.setup()` with references to `ToastManager` and `statusItem`
- [x] 3.3 Pass `toastManager` from `AppDelegate` through to `MenuBarController.setup()`
- [x] 3.4 Build and verify toasts appear when triggered (test with a hotkey press that shows "No text selected" or similar)

## 4. Animate Processing Menu Bar Icon

- [x] 4.1 In `MenuBarController`, add a `Timer` property for processing animation
- [x] 4.2 When `AppStatus` transitions to `.processing`, start a timer at ~4fps that rotates the `arrow.trianglehead.2.counterclockwise` SF Symbol through 0°, 120°, 240° rotation angles
- [x] 4.3 Create a helper method to generate a rotated `NSImage` from an SF Symbol
- [x] 4.4 When `AppStatus` transitions away from `.processing`, stop the timer and set the appropriate static icon
- [x] 4.5 Verify animation starts on hotkey trigger and stops on success/error/idle

## 5. Enhance Dropdown Status Display

- [x] 5.1 In `MenuBarDropdownView.statusBadge`, add a subtle pulse or activity indicator for the "processing" badge (e.g., opacity animation)
- [x] 5.2 Verify the dropdown correctly shows "processing", "done", "error" badges based on `appState.status`
- [x] 5.3 Verify the "needs access" badge with "Open Settings" button works when permission is not granted

## 6. Fix Provider Editor API Key Storage

- [x] 6.0 Fix `ProviderEditorView.save()` for new providers: generate a Keychain reference ID (`"provider-<UUID>"`), call `KeychainService.store(apiKey:forReference:)`, set `provider.apiKeyReference` to the reference ID
- [x] 6.0a Fix `ProviderEditorView.save()` for existing providers: when API key is changed, call `KeychainService.update(apiKey:forReference:)` using the existing `apiKeyReference`
- [x] 6.0b Fix `ProviderEditorView.loadProvider()` to load the actual API key from Keychain via `KeychainService.retrieve(forReference:)` instead of displaying the reference ID
- [x] 6.0c Fix `ProviderEditorView.deleteProvider()` to call `KeychainService.delete(forReference:)` to clean up the Keychain entry
- [x] 6.0d Write unit tests for provider editor Keychain integration
- [x] 6.0e Build and verify: create provider in Settings, press hotkey, confirm no "API key not found" error

## 7. Fix Text Replacement Reliability

- [x] 7.0 In `ToastOverlayController`, override `canBecomeKey` and `canBecomeMain` to return `false` on the NSPanel to prevent it from stealing keyboard focus
- [x] 7.0a In `TextReplaceService.replaceViaAccessibility()`, add verification: after setting `kAXSelectedTextAttribute`, re-read it and confirm the value matches. If mismatch, throw `ReplaceError.replaceFailedAX`
- [x] 7.0b In `TextReplaceService.replaceViaClipboard()`, add 50ms delay between clipboard write and `simulateCmdV()`, and 50ms delay between key-down and key-up events in `simulateCmdV()`
- [x] 7.0c Fix `replaceViaClipboard()` to throw on failure: after Cmd+V simulation, attempt to verify via AX read-back. If AX read-back shows text didn't change AND AX is available, throw `ReplaceError.replaceFailedClipboard`
- [x] 7.0d Update unit tests for `TextReplaceService` to cover the new verification and timing behavior
- [x] 7.0e Build and verify end-to-end: select text, press hotkey, confirm text is actually replaced in the target app

## 8. Integration Testing & Verification

- [x] 8.1 Write unit tests for `ToastManager` — verify `show()` sets `currentToast`, auto-dismiss timing, `dismiss()` clears toast, rapid replacement cancels previous timer
- [x] 8.2 Write unit tests for `MenuBarController` animation lifecycle — verify timer starts on `.processing`, stops on other states
- [ ] 8.3 Build and run the app end-to-end: trigger a hotkey, verify toast appears, icon animates during processing, icon returns to idle on completion
- [ ] 8.4 Verify toast does not steal focus from the active application
- [ ] 8.5 Verify toast is visible in full-screen mode
