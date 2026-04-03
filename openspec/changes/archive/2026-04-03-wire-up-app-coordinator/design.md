## Context

InDraft is a macOS menu bar app for AI-powered text transformation. The app was designed with a clean architecture:
- `AppDelegate` → entry point, creates `MenuBarController`
- `MenuBarController` → manages status item and popover
- `AppCoordinator` → orchestrates hotkeys, text capture, transformation, and replacement
- `HotkeyService` → Carbon-based global hotkey registration
- `TransformService` → coordinates capture → AI → replace pipeline

The `AppCoordinator` was fully implemented but never instantiated. As a result:
1. Global hotkeys are never registered with the system
2. Menu bar action clicks just dismiss the popover
3. No transformation ever occurs

The fix is straightforward: wire up the existing `AppCoordinator` and create the missing `ToastManager`.

## Goals / Non-Goals

**Goals:**
- Make hotkey-triggered text transformation functional
- Make menu bar click-triggered transformation functional
- Provide user feedback via toast notifications
- Update menu bar icon during processing states

**Non-Goals:**
- Changing the transformation logic (already implemented)
- Adding new hotkey features beyond what's defined
- Redesigning the UI/UX

## Decisions

### 1. Where to instantiate AppCoordinator

**Decision:** Create `AppCoordinator` in `AppDelegate.applicationDidFinishLaunching` and pass it to `MenuBarController`.

**Rationale:** AppDelegate owns the app lifecycle and is the natural root for all coordinators. MenuBarController needs a reference to call `triggerAction()` and `retryLast()`.

**Alternatives considered:**
- Creating in MenuBarController: Would work but puts coordination logic too deep in UI layer
- Creating as singleton: Works but makes testing harder and hides dependencies

### 2. ToastManager implementation

**Decision:** Create `ToastManager` as an `ObservableObject` that publishes toast state, consumed by a new `ToastView` in the menu bar dropdown.

**Rationale:** The existing `ToastView.swift` exists and expects a `ToastManager` to provide toast state. We just need to create the manager class.

**Alternatives considered:**
- Using Apple's native notifications: Would be more disruptive and less cohesive with the app UI
- Inline toast in dropdown: Already designed this way

### 3. Menu bar icon state updates

**Decision:** Have `MenuBarController` observe `AppState.status` and update the status item icon accordingly.

**Rationale:** `AppState` already has the status enum with `.idle`, `.processing`, `.success`, `.error`, `.permissionRequired` cases. The icon update method `updateIcon(for:)` exists but is never called.

**Alternatives considered:**
- Publishing state changes from AppCoordinator: AppState already does this via Combine

### 4. Wiring menu bar actions

**Decision:** Pass `AppCoordinator` reference to `MenuBarDropdownView` and call `coordinator.triggerAction(action)` when action rows are clicked.

**Rationale:** The `AppCoordinator.triggerAction(_ action: Action)` method already exists and handles the full transformation flow.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-------------|
| Hotkey conflicts with system shortcuts | Carbon API returns errors on conflicts; catch and show toast |
| Accessibility permission not granted | Already handled in `handleHotkeyPress` with toast message |
| Provider not configured | Already handled with error toast |
| Thread safety on AppState updates | AppState is `@MainActor`; TransformService uses actor isolation |