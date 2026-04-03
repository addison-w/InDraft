## 1. Project Setup & Foundation

- [x] 1.1 Create Xcode project as macOS app with SwiftUI lifecycle, LSUIElement=YES in Info.plist, targeting macOS 14+
- [x] 1.2 Set up project structure: App/, Models/, Services/, Views/, ViewModels/, Utilities/ directories per design.md
- [x] 1.3 Create design system: Theme struct with color palette (bone #F5F0EB, warm grays, charcoal text), typography styles (serif headlines, system body, monospaced labels), and reusable ViewModifiers matching design screenshots
- [x] 1.4 Set up test targets: unit test target and UI test target with protocol-based mock infrastructure

## 2. Data Models (SwiftData)

- [x] 2.1 TDD: Write tests for Action model — fields, defaults, validation (name required/unique, prompt required, max lengths)
- [x] 2.2 Implement Action SwiftData model with all fields per actions-engine spec
- [x] 2.3 TDD: Write tests for Provider model — fields, is_active constraint (exactly one active), enabled/disabled behavior
- [x] 2.4 Implement Provider SwiftData model with all fields per provider-management spec
- [x] 2.5 TDD: Write tests for HistoryRecord model — fields, snapshot names, status enum, retention pruning
- [x] 2.6 Implement HistoryRecord SwiftData model with all fields per transformation-history spec
- [x] 2.7 Implement seed data: 3 default actions with pre-configured names, prompts, hotkeys, and replace output behavior

## 3. Keychain Service

- [x] 3.1 TDD: Write tests for KeychainService protocol — store, retrieve, delete, update API keys by reference ID
- [x] 3.2 Implement KeychainService using Security framework with Keychain queries keyed by provider reference ID

## 4. Provider API Service

- [x] 4.1 TDD: Write tests for ProviderService protocol — build chat completion request, parse response, handle error codes (401, 404, timeout, invalid format)
- [x] 4.2 Implement ProviderService with URLSession async/await: POST /chat/completions with system prompt + user text, Authorization header from Keychain
- [x] 4.3 TDD: Write tests for connection testing — success with latency, auth failure, unreachable URL, model not found, timeout (10s), unexpected format
- [x] 4.4 Implement connection test method sending minimal "Reply with OK" request with all error case mapping

## 5. Text Capture Service

- [x] 5.1 Define TextCaptureService protocol with primary (AX) and fallback (clipboard) strategies
- [x] 5.2 TDD: Write tests for AX text capture — successful read, empty selection, AX unavailable triggers fallback
- [x] 5.3 Implement AX capture using AXUIElementCopyAttributeValue with kAXSelectedTextAttribute, 500ms timeout
- [x] 5.4 TDD: Write tests for clipboard fallback — save/capture/restore cycle, restore within 5s, total failure notification
- [x] 5.5 Implement clipboard fallback: save NSPasteboard, simulate Cmd+C via CGEvent, read clipboard, restore original

## 6. Text Replace Service

- [x] 6.1 Define TextReplaceService protocol with primary (AX) and fallback (clipboard) strategies
- [x] 6.2 TDD: Write tests for AX text replacement — successful write, write failure triggers fallback
- [x] 6.3 Implement AX replacement using AXUIElementSetAttributeValue with kAXSelectedTextAttribute
- [x] 6.4 TDD: Write tests for clipboard fallback — place text, simulate Cmd+V, restore clipboard within 30s, total failure copies to clipboard
- [x] 6.5 Implement clipboard replacement fallback with 30-second restore timer

## 7. Hotkey Service

- [x] 7.1 Define HotkeyService protocol — register, deregister, update hotkeys; conflict detection
- [x] 7.2 TDD: Write tests for hotkey registration — register/deregister, conflict detection within app, registration failure handling
- [x] 7.3 Implement HotkeyService wrapping Carbon RegisterEventHotKey API with Swift callback dispatch
- [x] 7.4 Implement hotkey recorder view component: Record/Clear buttons, key combination display, conflict warning

## 8. Transform Orchestration Service

- [x] 8.1 TDD: Write tests for TransformService — full pipeline: capture → API call → replace, with fallback chain and error handling at each stage
- [x] 8.2 Implement TransformService as Swift actor: serial queue, coordinates TextCaptureService → ProviderService → TextReplaceService
- [x] 8.3 TDD: Write tests for output behavior routing — replace triggers replacement, preview opens panel, clipboard copies only
- [x] 8.4 Implement output behavior dispatch: replace → TextReplaceService, preview → emit to preview panel, clipboard → NSPasteboard

## 9. History Service

- [x] 9.1 TDD: Write tests for HistoryService — create record on success/failure, search, delete, clear all, retention pruning
- [x] 9.2 Implement HistoryService: CRUD operations, search across action_name/source_app/original_text/transformed_text, auto-prune on launch
- [x] 9.3 Implement Retry Last: find most recent history record, re-run same action prompt on current selection

## 10. App State & Status Feedback

- [x] 10.1 TDD: Write tests for AppState state machine — idle→processing→success→idle, idle→processing→error→idle, permissionRequired persistent
- [x] 10.2 Implement AppState as ObservableObject with @Published state, 3s success auto-dismiss, 10s error auto-dismiss
- [x] 10.3 Implement toast notification system: overlay near menu bar, auto-dismiss timers (2s success, 5s error/fallback), no focus stealing

## 11. Menu Bar UI

- [x] 11.1 Implement MenuBarExtra with custom SwiftUI view: icon state driven by AppState
- [x] 11.2 Implement menu bar dropdown view: header (INDRAFT + provider/model), action list with hotkey badges, Retry Last, Open Settings, Open History, Quit InDraft — matching design 01-menu-bar-dropdown.png
- [x] 11.3 Implement menu bar icon states: idle (default), processing (spinner overlay), success (checkmark), error (red dot), permission-required (warning)

## 12. Settings Window

- [x] 12.1 Implement settings window shell: left sidebar with General/Actions/Providers/History/Diagnostics tabs, "InDraft Settings" title bar — matching design 07/10/11 screenshots
- [x] 12.2 Implement General tab: Launch at Login toggle (SMAppService), Show Dock Icon toggle (NSApp.setActivationPolicy), appearance, notification preferences
- [x] 12.3 Implement Actions tab: reorderable action list with name, hotkey badge, output behavior badge (REPLACE pill), enabled toggle, overflow menu (edit/duplicate/delete), "+ New Action" button, "Restore Defaults" — matching design 07-settings-actions.png
- [x] 12.4 Implement Action Editor modal: name field, prompt textarea, hotkey recorder with Record/Clear, output behavior selector (Replace/Preview/Clipboard segmented control), provider mode selector (Use Active/Fixed Provider), model override field, enabled toggle, Cancel/Save Action buttons — matching designs 08/09-action-editor-modal.png
- [x] 12.5 Implement Providers tab: provider cards with name, base URL, model, active badge (green), test status, actions (Edit/Test/Set Active), "+ Add Provider" button — matching design 10-settings-providers.png
- [x] 12.6 Implement Provider Editor modal: display name, base URL, API key (masked with Show toggle), default model, enabled toggle, Test Connection button
- [x] 12.7 Implement History tab: retention selector (7/30/90/unlimited), recording toggle, clear all button with confirmation, privacy note text
- [x] 12.8 Implement Diagnostics tab: Accessibility status (GRANTED/NOT GRANTED), hotkey registration count, provider connectivity status — matching design 11-settings-diagnostics.png

## 13. Onboarding Flow

- [x] 13.1 Implement onboarding window container: step indicator ("STEP X OF 6"), Back/Continue navigation, resume-at-incomplete-step persistence
- [x] 13.2 Implement Welcome step (Step 1): "Rewrite anything, anywhere." headline, description, "Get Started" button, "Takes about 2 minutes to set up" — matching design 02-onboarding-welcome.png
- [x] 13.3 Implement Accessibility Permission step (Step 2): explanation text, System Settings link, real-time permission status polling, Continue disabled until granted — matching design 03-onboarding-accessibility.png
- [x] 13.4 Implement Add Provider step (Step 3): form with display name, base URL (pre-filled https://api.openai.com/v1), API key (masked), default model — matching designs 04/05-onboarding-add-provider.png
- [x] 13.5 Implement Test Connection step (Step 4): test button, loading/success/error states, Continue disabled until test passes
- [x] 13.6 Implement Default Actions step (Step 5, skippable): display 3 default actions with hotkey combinations
- [x] 13.7 Implement Sample Transformation step (Step 6, skippable): text area with sample text, "Try It" button running Rewrite for Clarity
- [x] 13.8 Implement Complete step (Step 7): "You're all set." with checkmark, default actions list with hotkeys, set provider as active — matching design 06-onboarding-complete.png

## 14. History Window

- [x] 14.1 Implement history window: search bar, retention filter badge, Clear All button, filter icon — matching design 12-transformation-history.png
- [x] 14.2 Implement history record rows: timestamp, source app badge, action name (italic), latency, status badge (SUCCESS/ERROR), expandable original vs. transformed text
- [x] 14.3 Implement record actions: Copy Original, Copy Result, Retry, Delete buttons per record
- [x] 14.4 Implement history record detail: original text (left) and transformed text (right) side by side with distinct styling — matching design 12/15-history screenshots

## 15. Preview Panel

- [x] 15.1 Implement floating preview panel: "InDraft" title, ORIGINAL and TRANSFORMED columns, Reject/Copy/Accept buttons — matching designs 13/14-preview-panel.png
- [x] 15.2 Implement panel behavior: floating window level (NSWindow.Level.floating), no focus stealing, Accept triggers replacement, Reject dismisses, Copy sends to clipboard

## 16. Integration & Polish

- [x] 16.1 Wire hotkey triggers to TransformService pipeline: hotkey press → capture → API → output behavior routing → status feedback → history recording
- [x] 16.2 Wire menu bar dropdown actions to TransformService (for actions triggered via menu instead of hotkey)
- [x] 16.3 Implement Accessibility permission checking: AXIsProcessTrustedWithOptions, real-time polling for onboarding, diagnostic status
- [x] 16.4 Integration test: full transformation flow across TextEdit, Notes, Safari, Chrome, Slack (top 5 apps)
- [x] 16.5 Integration test: clipboard fallback chain — verify save/restore, timing constraints, no clipboard corruption
- [x] 16.6 Integration test: error paths — no selection, provider failure, replacement failure, incomplete setup hotkey press
- [x] 16.7 Verify all design system consistency: bone palette, serif headlines, monospaced hotkey labels, flat cards, minimal shadows across all views
- [x] 16.8 Test launch-at-login, dock icon toggle, and app lifecycle (background process, no main window)
