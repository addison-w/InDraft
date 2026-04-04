## ADDED Requirements

### Requirement: Active provider displayed in dropdown header
The menu bar dropdown header SHALL display the active provider's display name (not model name). If no provider is active, a warning message SHALL be shown.

#### Scenario: Active provider shown in dropdown
- **WHEN** the user opens the menu bar dropdown with an active provider configured
- **THEN** the dropdown header shows "PROVIDER" label followed by the provider's display name (e.g., "Claude", "OpenAI", "Local")

#### Scenario: No active provider warning
- **WHEN** the user opens the menu bar dropdown with no active provider
- **THEN** the dropdown header shows "No provider configured" instead of a provider name