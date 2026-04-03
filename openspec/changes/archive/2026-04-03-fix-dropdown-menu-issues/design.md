## Context

The dropdown menu has several bugs and UX issues that need fixing. The current implementation:
- Uses `SettingsWindowController.shared.showSettings()` for settings but has no equivalent for history
- Has hardcoded "OpenAI · gpt-4o" placeholder text for provider display
- Has verbose menu labels ("Open Settings...", "Open History...")
- Includes "Retry Last" which adds clutter

## Goals / Non-Goals

**Goals:**
- Fix window activation to bring windows to front when opened from dropdown
- Make "Open History" functional by creating a HistoryWindowController
- Simplify menu item labels to "Settings" and "History"
- Remove "Retry Last" functionality entirely
- Display actual active provider name (not model name) in dropdown header

**Non-Goals:**
- Changing the visual design of the dropdown
- Modifying hotkey handling
- Adding new features to History window

## Decisions

### 1. History Window Controller

**Decision:** Create `HistoryWindowController` singleton matching the pattern of `SettingsWindowController`.

**Rationale:** Settings uses a dedicated window controller for proper window lifecycle management. History should follow the same pattern for consistency and to fix the non-functional "Open History" button.

**Alternative considered:** Open History via SwiftUI sheet — rejected because history should be a standalone window like settings, not tied to the dropdown.

### 2. Window Activation

**Decision:** Both `SettingsWindowController` and `HistoryWindowController` will call `makeKeyAndOrderFront(nil)` followed by `NSApp.activate()` when showing windows.

**Rationale:** This ensures the window comes to front and becomes key, even if it was already open but hidden behind other windows.

### 3. Provider Display

**Decision:** Query the active provider from SwiftData and display `displayName` only (not model name).

**Rationale:** The spec requires showing provider name in dropdown header. Current hardcoded text is a placeholder. Model name adds unnecessary detail — users know their configured model.

**Implementation:** In `MenuBarDropdownView`, use `@Query(filter:)` to get the active provider and display its `displayName`.

### 4. Menu Item Labels

**Decision:** Shorten labels to "Settings" and "History" (remove "Open..." prefix).

**Rationale:** Cleaner UI, follows macOS conventions (e.g., menu items typically just say "Settings").

### 5. Retry Last Removal

**Decision:** Remove the entire "Retry Last" menu item and its associated `retryLast()` method.

**Rationale:** Adds UI clutter without sufficient value. Users can re-trigger actions via hotkey. Can be re-added later if needed.

## Risks / Trade-offs

- **Risk:** Querying active provider on each render could be expensive. → Mitigation: SwiftData `@Query` is efficient and cached; this is a small dataset.
- **Risk:** Removing Retry Last may surprise users. → Mitigation: Feature was never released; no migration needed.