## MODIFIED Requirements

### Requirement: App initialization sequence

The system SHALL initialize all coordinators and services during app launch.

**Previous behavior:** AppDelegate created MenuBarController which seeded default actions but did not create AppCoordinator.

**New behavior:** AppDelegate creates AppCoordinator, ToastManager, and passes them to MenuBarController for complete initialization.

#### Scenario: App launch initializes coordinator
- **WHEN** the app finishes launching
- **THEN** the system SHALL create AppCoordinator with ToastManager, set up hotkey registrations, and check accessibility permissions

#### Scenario: Hotkey service registration
- **WHEN** AppCoordinator.setup() is called
- **THEN** all enabled actions with hotkeys SHALL be registered with the HotkeyService