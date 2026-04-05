## Why

Users and support have no way to identify which version of InDraft is running without opening Finder → Get Info. Displaying the version number in the menu bar dropdown and settings sidebar provides instant visibility, aids troubleshooting, and adds a polished, professional touch to the UI.

## What Changes

- **Add version label to menu bar dropdown**: Display the app version (e.g., "v1.2.0") in the header section, aligned to the top-right area alongside the "InDraft" title
- **Add version label to settings sidebar**: Display the version at the bottom-left of the sidebar, below the navigation tabs, styled as tertiary metadata

## Non-goals

- Build number display (only marketing version / CFBundleShortVersionString)
- Update checking or notification system
- Version history or changelog UI
- Any changes to window management or activation policy

## Capabilities

### New Capabilities
- `version-display`: Displays the app version string in the menu bar dropdown header and settings sidebar footer, sourced from the app bundle

### Modified Capabilities
_None — this is purely additive UI, no existing spec-level requirements change._

## Impact

- **MenuBarDropdownView.swift**: Add version text to the header section
- **SettingsView.swift**: Add version text to the sidebar, below the tab list
- **Services affected**: None
- **Models affected**: None
- **macOS API constraints**: None (Bundle.main.infoDictionary is available on all macOS versions)
- **Complexity**: **S** — two small UI additions reading from Bundle.main
