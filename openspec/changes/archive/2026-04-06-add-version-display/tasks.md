## 1. Add Version to Menu Bar Dropdown Header

- [x] 1.1 Add version text to the header section of `MenuBarDropdownView`, right-aligned on the "InDraft" title line, using `Theme.Typography.mono(9)` in `Theme.Colors.textTertiary`, formatted as "v{version}" from `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` with empty string fallback

## 2. Add Version to Settings Sidebar Footer

- [x] 2.1 Add version text after the `Spacer()` in the `SettingsView` sidebar, anchored to the bottom-left, using `Theme.Typography.mono(9)` in `Theme.Colors.textTertiary`, formatted as "v{version}" with the same bundle source and fallback

## 3. Verify

- [x] 3.1 Build the project and confirm no compilation errors
- [x] 3.2 Run existing tests to verify no regressions
- [ ] 3.3 Visually verify the menu bar dropdown shows the version in the header
- [ ] 3.4 Visually verify the settings sidebar shows the version at the bottom
