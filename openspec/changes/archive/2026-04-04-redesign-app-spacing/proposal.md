# Proposal: Redesign App Spacing for Premium Minimalist Aesthetic

## Why

InDraft's current UI feels cramped and lacks the breathing room characteristic of premium minimalist design. The spacing scale uses tight values (xs/sm) where generous whitespace is needed, lists have minimal vertical separation, and critical surfaces like the menu bar dropdown (260px width) feel constrained. This redesign establishes macro-whitespace principles aligned with the "Technical Curator" design direction—elevating the app from functional to refined editorial quality.

## What Changes

- **BREAKING**: Increase spacing scale baseline (xs: 4→6, sm: 8→12, md: 12→20, lg: 16→28, xl: 24→40)
- **BREAKING**: Add new `xxl: 56` and `xxxl: 80` tokens for section-level spacing
- Widen MenuBarDropdown from 260px to 300px for better text breathing room
- Increase menu item vertical padding from 6pt to 10pt
- Add generous section padding (40-56pt) to all primary views
- Improve list row spacing from `xs` to `md` minimum
- Increase SettingsView sidebar width from 140-160px to 180-200px
- Add consistent 32pt bottom padding to all scrollable content
- Increase OnboardingContainerView frame to 540×480 for better proportions
- Update card padding from implicit to explicit 24-32pt minimum
- Add line-height guidance to typography (1.5 for body, 1.3 for headings)
- Increase HistoryWindowView row spacing from xs to md

## Capabilities

### New Capabilities

- `spacing-system`: Defines the unified spacing scale, semantic naming conventions, and application guidelines for macro-whitespace across all screens
- `typographic-hierarchy`: Establishes line-height ratios, tracking values, and vertical rhythm principles for editorial-grade typography

### Modified Capabilities

- `settings-ui`: Updates settings window layout with improved spacing, wider sidebar, and section breathing room
- `onboarding-flow`: Adjusts onboarding container dimensions and internal spacing for better visual balance

## Impact

**Affected Files:**
- `InDraft/Utilities/Theme.swift` — spacing scale overhaul, typography additions
- `InDraft/Views/MenuBar/MenuBarDropdownView.swift` — width increase, padding adjustments
- `InDraft/Views/MenuBar/MenuBarRowView.swift` — row height, padding updates
- `InDraft/Views/Settings/SettingsView.swift` — sidebar width, section spacing
- `InDraft/Views/Settings/ActionsSettingsView.swift` — list spacing, card padding
- `InDraft/Views/Settings/ProvidersSettingsView.swift` — consistent spacing
- `InDraft/Views/Settings/GeneralSettingsView.swift` — form spacing
- `InDraft/Views/Settings/HistorySettingsView.swift` — list spacing
- `InDraft/Views/Onboarding/OnboardingContainerView.swift` — frame dimensions
- `InDraft/Views/History/HistoryWindowView.swift` — row spacing, padding
- `InDraft/Views/History/HistoryRecordRowView.swift` — internal padding

**Complexity:** Medium (M)
- Non-breaking visual change affecting all views
- Requires visual verification of each screen
- No API changes or service modifications
- Can be implemented incrementally by screen

**Rollback Plan:**
- Revert spacing changes by restoring original Theme.Spacing values
- All changes are cosmetic and isolated to View layer
- No data migration or persistence changes

## Non-goals

- Color palette changes (handled separately in Theme system)
- Typography font changes (Manrope/Inter are correct)
- Icon changes or additions
- New UI components beyond spacing adjustments
- Animation or motion changes
- macOS version requirements (remains macOS 14+)