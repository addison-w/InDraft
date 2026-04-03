## Why

The core text transformation function is completely non-functional. When a user selects text and presses a registered hotkey (e.g., Ctrl+Opt+1), nothing happens—the text is not captured, processed, or replaced. Investigation reveals that `AppCoordinator`, the orchestrator responsible for hotkey registration and transformation coordination, is defined but never instantiated or wired up in the application.

## What Changes

- **Instantiate `AppCoordinator`** in `AppDelegate` and call its `setup()` method during launch
- **Create `ToastManager`** (referenced but never implemented) for user feedback
- **Wire menu bar dropdown actions** to `AppCoordinator.triggerAction()` for click-based transformation triggers
- **Wire "Retry Last"** to `AppCoordinator.retryLast()` functionality
- **Connect menu bar icon updates** to `AppState` status changes for visual feedback during processing

## Capabilities

### New Capabilities

- `hotkey-processing`: Global hotkey detection and routing to registered actions
- `text-transformation`: End-to-end text capture → AI transformation → text replacement flow
- `menu-action-trigger`: Menu bar dropdown action execution (clicking action rows)

### Modified Capabilities

- `app-lifecycle`: AppDelegate initialization now includes coordinator setup

## Impact

- **Files Modified**:
  - `InDraft/App/AppDelegate.swift` - instantiate and configure `AppCoordinator`
  - `InDraft/Views/MenuBar/MenuBarDropdownView.swift` - wire action rows to coordinator
  - `InDraft/App/MenuBarController.swift` - receive coordinator reference, update icon on state changes
  - `InDraft/App/AppCoordinator.swift` - expose methods for menu bar interaction
- **New Files**:
  - `InDraft/Services/ToastManager.swift` - toast notification management (referenced in `AppCoordinator` but never created)
- **Dependencies**: No new external dependencies