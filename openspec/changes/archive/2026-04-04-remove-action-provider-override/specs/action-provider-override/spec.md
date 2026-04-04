## REMOVED Requirements

### Requirement: Per-action provider override
**Reason**: Unused complexity. All actions currently use the active provider. Removing to simplify the Action model and editor UI.
**Migration**: Actions always use the active provider's default model. No user action required.

#### Scenario: Action uses active provider
- **WHEN** a user triggers any action
- **THEN** the system SHALL use the active provider and its default model

### Requirement: Per-action model override
**Reason**: Removed alongside provider override. Model selection is determined by the active provider's `defaultModel`.
**Migration**: Remove `modelOverride` field. Active provider's default model is always used.

#### Scenario: No model override field in action editor
- **WHEN** a user expands an action in the editor
- **THEN** no model override text field SHALL be displayed

### Requirement: Provider mode selection UI
**Reason**: Removed alongside provider override. No UI needed to choose between active/fixed provider.
**Migration**: Remove PROVIDER section from action editor and new action form.

#### Scenario: No provider section in action editor
- **WHEN** a user expands an action in the editor
- **THEN** no provider mode picker or provider dropdown SHALL be displayed
