## ADDED Requirements

### Requirement: App-wide dark color scheme
The app SHALL provide a complete dark color scheme that applies to all windows: menu bar dropdown, settings, history, onboarding, preview panel, and toast notifications. The dark scheme SHALL use warm dark grays (not pure black) to maintain the editorial design aesthetic.

#### Scenario: App renders in dark mode
- **WHEN** the appearance preference is set to Dark
- **THEN** all windows render with dark backgrounds, light text, and adjusted accent colors

#### Scenario: Dark mode preserves design identity
- **WHEN** the app is in dark mode
- **THEN** the warm editorial aesthetic is maintained with warm dark grays instead of pure black, and muted accent colors instead of harsh bright ones

### Requirement: Appearance preference with three modes
The app SHALL provide an appearance preference with three options: System (follows macOS), Light (always light), and Dark (always dark). The default SHALL be System.

#### Scenario: System appearance follows macOS
- **WHEN** the appearance preference is set to System AND macOS is in dark mode
- **THEN** the app renders in dark mode

#### Scenario: System appearance follows macOS light
- **WHEN** the appearance preference is set to System AND macOS is in light mode
- **THEN** the app renders in light mode

#### Scenario: Manual light override
- **WHEN** the appearance preference is set to Light AND macOS is in dark mode
- **THEN** the app renders in light mode regardless of system setting

#### Scenario: Manual dark override
- **WHEN** the appearance preference is set to Dark AND macOS is in light mode
- **THEN** the app renders in dark mode regardless of system setting

### Requirement: Appearance preference persisted
The appearance preference SHALL be stored in UserDefaults and persist across app launches.

#### Scenario: Preference survives restart
- **WHEN** the user sets appearance to Dark and restarts the app
- **THEN** the app launches in dark mode

### Requirement: Appearance preference in settings
The appearance preference selector SHALL appear in Settings > General.

#### Scenario: Appearance selector in General settings
- **WHEN** the user opens Settings > General
- **THEN** an appearance selector is visible with System, Light, and Dark options

### Requirement: Semantic color tokens
All color references in views SHALL use semantic color tokens that automatically resolve to the correct value based on the current appearance. Views SHALL NOT branch on `colorScheme` to select colors.

#### Scenario: Color resolution is automatic
- **WHEN** the app switches from light to dark mode
- **THEN** all colors update automatically without per-view logic

### Requirement: Menu bar icon adapts to appearance
The menu bar status item icon SHALL be legible in both light and dark menu bars.

#### Scenario: Icon visible on dark menu bar
- **WHEN** macOS uses a dark menu bar
- **THEN** the InDraft menu bar icon is clearly visible with appropriate contrast

#### Scenario: Icon visible on light menu bar
- **WHEN** macOS uses a light menu bar
- **THEN** the InDraft menu bar icon is clearly visible with appropriate contrast
