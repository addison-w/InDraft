## Context

Currently accessibility permission is checked once in `AppCoordinator.setup()` via `AccessibilityService.isAccessibilityGranted`. If not granted, `appState.setPermissionRequired()` is called. There is no mechanism to detect when the user subsequently grants permission — the app stays in `permissionRequired` state until restarted.

The onboarding `AccessibilityStepView` already implements 1-second polling with `Timer.scheduledTimer` — this is the proven pattern in the codebase.

The dropdown uses `@Query(sort: \Action.sortOrder)` which returns all actions. It does not filter by `action.enabled`, showing disabled actions that can't be triggered.

## Goals / Non-Goals

**Goals:**
- Poll accessibility status in `AppCoordinator` when in `permissionRequired` state, transitioning to `idle` and re-registering hotkeys when granted
- Poll accessibility status in `DiagnosticsSettingsView` while the view is visible
- Filter dropdown action list to enabled actions only

**Non-Goals:**
- Adding a `@Published var accessibilityGranted` to AppState (unnecessary — the `.permissionRequired` status already conveys this)
- Polling when permission is already granted (waste of resources)
- Changing the `@Query` to use a predicate filter (SwiftUI `@Query` filter predicates on Bool properties can be unreliable with SwiftData — use `.filter` in the view instead)

## Decisions

### Decision 1: Poll in AppCoordinator, not AppState

**Choice**: Add a `Timer` in `AppCoordinator` that starts when status is `permissionRequired` and stops when permission is granted. On grant, call `appState.setIdle()` and `registerAllHotkeys()`.

**Rationale**: `AppCoordinator` already owns the relationship between permission state, `appState`, and hotkey registration. Keeping the polling here avoids adding timer logic to `AppState` (which is a simple observable state container).

**Alternative considered**: Adding polling to `AppState`. Rejected because AppState doesn't know about hotkey registration and shouldn't — it's a pure state container.

### Decision 2: Poll in DiagnosticsSettingsView with onAppear/onDisappear lifecycle

**Choice**: Start a 2-second polling timer in `onAppear`, invalidate in `onDisappear`. Update `@State var accessibilityGranted` on each tick.

**Rationale**: Matches the onboarding pattern. Only polls while the view is visible — no resource waste. 2-second interval (vs 1-second in onboarding) is sufficient for a settings screen.

### Decision 3: Filter actions in view body, not @Query predicate

**Choice**: Use `actions.filter { $0.enabled }` in the dropdown view body instead of adding a `#Predicate` to `@Query`.

**Rationale**: SwiftData `@Query` with `#Predicate` on non-optional Bool fields works but adds complexity. A simple `.filter` in the view is clear, correct, and consistent with how other views handle this.

## Testability

- **Unit test**: AppCoordinator accessibility polling — mock accessibility service, verify timer starts in permissionRequired state and calls setIdle + registerAllHotkeys when granted
- **Visual verification**: Revoke accessibility, launch app, grant permission in System Settings, verify dropdown updates within seconds without restart

## Risks / Trade-offs

- **[Low] Polling resource usage**: `AXIsProcessTrusted()` is a lightweight syscall. 1-2 second intervals are negligible.
- **[Low] Timer lifecycle**: AppCoordinator timer must be invalidated in deinit. DiagnosticsSettingsView timer must be invalidated in onDisappear. Both are standard patterns already used in the codebase.
