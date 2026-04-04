## Why

The current settings and history windows use macOS system traffic light buttons (close/minimize/maximize) which clash with InDraft's warm, minimal design aesthetic. Additionally, the settings screen's navigation bar toggle feels visually heavy and inconsistent with the app's otherwise clean, utilitarian interface. This change aligns these UI elements with the "Technical Curator" design direction—creating a cohesive, premium feel throughout the app.

## What Changes

- **Custom Window Chrome**: Replace system traffic light buttons with custom-designed window controls in both Settings and History windows
  - Three subtle circular buttons (close, minimize, zoom) using warm monochrome palette
  - Icons appear on hover to maintain minimal appearance
  - Positioned in top-left corner matching macOS convention
- **Settings Navigation Redesign**: Replace the current segmented control-style nav toggle with a minimalist tab bar
  - Clean text-based tabs with subtle active state indicator
  - No background pills or heavy borders—just typographic hierarchy
  - Smooth underline or tonal shift for active state
- **Window Title Styling**: Remove system window title bars where possible, use custom title treatment integrated into the content area

## Capabilities

### New Capabilities
- `custom-window-chrome`: Custom window controls that replace system traffic lights with app-styled buttons
- `minimalist-settings-nav`: Redesigned settings navigation using typographic tabs instead of segmented controls

### Modified Capabilities
- None—this is purely a visual redesign with no behavior changes

## Impact

- **Affected Views**: Settings window, History window, and their respective view controllers
- **Services**: Window management in AppCoordinator, SettingsWindowController, HistoryWindowController
- **Design System**: Updates to theme tokens for window chrome and navigation components
- **Platform**: macOS 14+ (no API changes required)
- **Complexity**: M (Medium)

## Non-goals

- No changes to window behavior (dragging, resizing, full-screen)
- No changes to keyboard shortcuts or window management
- No new windows or navigation flows
- No changes to the menu bar dropdown UI

## Rollback Plan

If issues arise, revert to system traffic lights by:
1. Setting `titlebarAppearsTransparent = false` on window controllers
2. Restoring the original segmented control navigation
3. All changes are UI-only, no data migration needed
