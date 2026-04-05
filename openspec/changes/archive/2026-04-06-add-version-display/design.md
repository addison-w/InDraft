## Context

InDraft currently has no version indicator anywhere in its UI. The app version is only discoverable via Finder → Get Info. Both the menu bar dropdown (`MenuBarDropdownView`) and settings window (`SettingsView`) have natural locations for a version label — the dropdown header and the settings sidebar footer respectively.

The version string is available via `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` which returns the marketing version (e.g., "1.2.0").

No services, protocols, models, or window controllers need modification. This is purely additive SwiftUI view changes.

## Goals / Non-Goals

**Goals:**
- Display the app version in the menu bar dropdown header (top-right, beside "InDraft" title)
- Display the app version in the settings sidebar footer (bottom-left, below navigation tabs)
- Style both labels as unobtrusive tertiary metadata consistent with the editorial design system

**Non-Goals:**
- Build number display
- Update checking or auto-update functionality
- Version string caching or abstraction layer
- Changes to AppCoordinator, window controllers, or any service protocol

## Decisions

### 1. Version string source: Bundle.main directly

**Rationale**: `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` is the standard macOS API for reading the marketing version. It's a synchronous, cached read with zero overhead. No wrapper or helper needed — inline it where used.

**Alternative considered**: Creating a dedicated `AppInfo` utility enum — rejected as unnecessary abstraction for two call sites.

### 2. Menu bar dropdown: Version in header subtitle row

**Rationale**: The header already has a subtitle row showing `providerDisplayName · model`. Adding the version as the last element in this row (right-aligned, after the status badge) would clutter it. Instead, place it on the same line as "InDraft" title, right-aligned, using mono typography at a small size. This follows the minimalist editorial pattern — metadata as quiet, tertiary text that's visible but never competing for attention.

**Layout**: `HStack { Text("InDraft") ... Spacer() ... Text("v1.2.0") }`

**Typography**: `Theme.Typography.mono(9)` in `Theme.Colors.textTertiary` — matches the existing metadata style used for model names.

### 3. Settings sidebar: Version at bottom of sidebar

**Rationale**: The sidebar has a `Spacer()` pushing content to the top. The version label goes after the spacer, anchored to the bottom-left of the sidebar. Uses the same tertiary mono style for consistency.

**Typography**: `Theme.Typography.mono(9)` in `Theme.Colors.textTertiary`, with generous left padding matching the sidebar content alignment.

### 4. Version format: "v" prefix

**Rationale**: Display as "v1.2.0" rather than bare "1.2.0". The "v" prefix is a universal convention that immediately signals "this is a version number" without additional labeling.

## Testability

- No new protocols or services — no mock implementations needed
- No AppKit/SwiftUI bridging required
- Visual verification: Build and check both locations show the correct version
- Unit test: Optional — could test that `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` is non-nil, but this is a framework guarantee

## Risks / Trade-offs

- **[Version string nil]** → `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` could theoretically return nil in unusual build configurations. Mitigation: use nil-coalescing with empty string fallback, so the label simply doesn't appear rather than crashing.
- **[Visual clutter in dropdown header]** → Adding text to the header row risks feeling crowded. Mitigation: use very small mono font (9pt) in tertiary color, which blends into the background unless specifically looked for.
