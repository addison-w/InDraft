## ADDED Requirements

### Requirement: Floating toast overlay window
The app SHALL display toast notifications in a floating, non-activating overlay window positioned near the menu bar status item. The overlay SHALL NOT steal focus from the user's active application. The overlay SHALL use `NSPanel` with `.nonactivatingPanel` style mask.

#### Scenario: Toast appears near menu bar on success
- **WHEN** a transformation completes successfully
- **THEN** a toast with "Text replaced" message SHALL appear below the menu bar status item
- **AND** the toast SHALL auto-dismiss after 2 seconds
- **AND** the user's active application SHALL retain focus

#### Scenario: Toast appears near menu bar on error
- **WHEN** a transformation fails
- **THEN** a toast with the error description SHALL appear below the menu bar status item
- **AND** the toast SHALL auto-dismiss after 5 seconds
- **AND** the toast SHALL include actionable guidance (e.g., "check Settings > Providers")

#### Scenario: Toast appears for info messages
- **WHEN** the app needs to show an informational message (e.g., "No text selected", clipboard fallback)
- **THEN** a toast with the info message SHALL appear below the menu bar status item
- **AND** the toast SHALL auto-dismiss after 3 seconds

#### Scenario: Toast does not steal focus
- **WHEN** any toast notification appears
- **THEN** the overlay panel SHALL use `NSPanel` with `.nonactivatingPanel` style
- **AND** the panel SHALL have window level at or above `.statusBar`
- **AND** the user's frontmost application SHALL remain frontmost

#### Scenario: Toast visible above all windows
- **WHEN** a toast is displayed
- **THEN** the toast SHALL be visible above all normal and floating windows
- **AND** the toast SHALL be visible even when the user is in a full-screen application

### Requirement: Toast click-to-dismiss
The user SHALL be able to dismiss a toast early by clicking on it.

#### Scenario: Click to dismiss toast
- **WHEN** a toast is visible AND the user clicks on it
- **THEN** the toast SHALL dismiss immediately with a fade-out animation

### Requirement: Toast animation
Toast appearance and disappearance SHALL be animated for a polished user experience.

#### Scenario: Toast fade in
- **WHEN** a new toast is triggered
- **THEN** the toast SHALL fade in over 0.2 seconds with ease timing

#### Scenario: Toast fade out
- **WHEN** a toast is dismissed (auto or manual)
- **THEN** the toast SHALL fade out over 0.15 seconds with ease timing

#### Scenario: Rapid toast replacement
- **WHEN** a new toast is triggered while a previous toast is still visible
- **THEN** the previous toast SHALL be replaced immediately by the new toast
- **AND** only the new toast's auto-dismiss timer SHALL be active

### Requirement: Toast visual design follows design system
The toast SHALL follow "The Technical Curator" design system: warm bone background, ghost borders, ambient diffusion elevation, Inter typography.

#### Scenario: Toast renders with correct styling
- **WHEN** a toast is displayed
- **THEN** the background SHALL use `Theme.Colors.cardBackground`
- **AND** the border SHALL use `Theme.Colors.cardBorder` as a ghost border
- **AND** the shadow SHALL use ambient diffusion (blur 12, y-offset 4, opacity 0.08)
- **AND** the corner radius SHALL use `Theme.Radius.md`
- **AND** the message text SHALL use Inter at 12pt
- **AND** the icon SHALL be an SF Symbol at 14pt with color matching the toast type

### Requirement: Single canonical ToastManager
The app SHALL have exactly one `ToastManager` class definition and one `ToastType` enum definition. Duplicate definitions SHALL be removed.

#### Scenario: No duplicate ToastManager or ToastType definitions
- **WHEN** the app is compiled
- **THEN** there SHALL be exactly one `ToastManager` class in the codebase
- **AND** there SHALL be exactly one `ToastType` enum in the codebase
- **AND** the `ToastType` enum SHALL use associated `String` values for each case (`.success(String)`, `.error(String)`, `.info(String)`)
