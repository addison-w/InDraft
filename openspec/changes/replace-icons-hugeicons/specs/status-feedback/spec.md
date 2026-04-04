## MODIFIED Requirements

### Requirement: Menu bar status icons use Hugeicons
The menu bar status item SHALL display Hugeicons-based icons for idle, success, error, and permission-required states, rendered as NSImage via `AppIcon.nsImage()`.

#### Scenario: Idle state icon
- **WHEN** the app status is `.idle`
- **THEN** the menu bar SHALL display the `AppIcon.edit` icon rendered as NSImage

#### Scenario: Success state icon
- **WHEN** the app status is `.success`
- **THEN** the menu bar SHALL display the `AppIcon.success` icon rendered as NSImage

#### Scenario: Error state icon
- **WHEN** the app status is `.error`
- **THEN** the menu bar SHALL display the `AppIcon.error` icon rendered as NSImage

#### Scenario: Permission required state icon
- **WHEN** the app status is `.permissionRequired`
- **THEN** the menu bar SHALL display the `AppIcon.warning` icon rendered as NSImage

#### Scenario: Processing state unchanged
- **WHEN** the app status is `.processing`
- **THEN** the menu bar SHALL continue to display the custom bouncing ball animation (not a Hugeicons icon)

### Requirement: Toast notification icons use Hugeicons
The toast overlay SHALL display Hugeicons-based icons for success, error, and info toast types.

#### Scenario: Success toast icon
- **WHEN** a success toast is displayed
- **THEN** the toast SHALL show the `AppIcon.success` icon

#### Scenario: Error toast icon
- **WHEN** an error toast is displayed
- **THEN** the toast SHALL show the `AppIcon.error` icon

#### Scenario: Info toast icon
- **WHEN** an info toast is displayed
- **THEN** the toast SHALL show the `AppIcon.info` icon

### Requirement: Action menu dynamic icons use Hugeicons
The menu bar dropdown SHALL display Hugeicons-based icons for each action, mapped by action name pattern.

#### Scenario: Dynamic icon assignment by action name
- **WHEN** an action is displayed in the menu bar dropdown
- **THEN** the icon SHALL be determined by the action name pattern using `AppIcon` equivalents (e.g., "rewrite" → edit icon, "grammar" → checkmark icon, "shorten" → compress icon)

#### Scenario: Default action icon
- **WHEN** an action name does not match any known pattern
- **THEN** the menu bar dropdown SHALL display a default text-align icon from Hugeicons
