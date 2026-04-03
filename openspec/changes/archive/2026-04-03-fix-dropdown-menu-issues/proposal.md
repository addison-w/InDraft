## Why

The dropdown menu has several usability issues: window management doesn't bring windows to front when activated, the "Open History" action is non-functional, menu item labels are verbose, the "Retry Last" function adds clutter without sufficient value, and the provider display shows incorrect placeholder text instead of the actual active provider name. These issues degrade the user experience and need to be fixed.

## What Changes

- **Fix window activation**: When clicking "Settings" or "History" from the dropdown, bring the window to the front (make it key window)
- **Fix History action**: "Open History" currently does nothing when clicked - make it functional
- **Rename menu items**: Change "Open Settings" → "Settings" and "Open History" → "History" for cleaner UI
- **Remove Retry Last**: Remove the "Retry Last" function and its menu item entirely
- **Fix provider display**: Show the actual active provider name (e.g., "Claude", "OpenAI") instead of showing the model name or placeholder text

## Capabilities

### New Capabilities

None - this is a bug fix and polish change.

### Modified Capabilities

- `settings-ui`: Menu item labels are being simplified and the "Retry Last" action is being removed
- `app-core`: Window management behavior when activating settings/history windows from dropdown
- `provider-management`: Provider display in dropdown should show provider name, not model name

## Impact

- `InDraft/Views/MenuBar/MenuBarDropdownView.swift` - Menu item text changes, retry last removal
- `InDraft/App/InDraftApp.swift` - Window management for settings/history activation
- `InDraft/Views/Settings/` - Settings window activation
- `InDraft/Views/History/` - History window activation (fix broken action)
- Provider display logic - Show provider name instead of model name