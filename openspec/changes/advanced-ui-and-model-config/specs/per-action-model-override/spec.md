## ADDED Requirements

### Requirement: Per-action provider mode UI
The action editor in Settings > Actions SHALL include a provider mode selector with two options: "Active" (uses global active provider) and "Fixed" (uses a specific provider).

#### Scenario: Default provider mode is Active
- **WHEN** a new action is created
- **THEN** the provider mode defaults to Active

#### Scenario: Select fixed provider mode
- **WHEN** the user selects "Fixed" provider mode in the action editor
- **THEN** a provider dropdown and model override field appear

#### Scenario: Active mode hides provider picker
- **WHEN** the user selects "Active" provider mode in the action editor
- **THEN** the provider dropdown and model override field are hidden AND helper text "Uses global active provider" is shown

### Requirement: Provider dropdown shows enabled providers
When provider mode is "Fixed", the action editor SHALL display a dropdown listing all enabled providers.

#### Scenario: Provider dropdown populated
- **WHEN** the user selects Fixed mode AND there are 3 enabled providers
- **THEN** the dropdown lists all 3 enabled providers by display name

#### Scenario: No enabled providers
- **WHEN** the user selects Fixed mode AND no providers are enabled
- **THEN** the dropdown shows "No providers available" and the user cannot save the fixed assignment

### Requirement: Model override field
When provider mode is "Fixed", the action editor SHALL display an optional model override text field. If left empty, the provider's default model is used.

#### Scenario: Custom model override
- **WHEN** the user sets provider mode to Fixed, selects a provider, and enters "gpt-4o" as model override
- **THEN** transformations for this action use the specified provider with "gpt-4o" instead of the provider's default model

#### Scenario: Empty model override uses provider default
- **WHEN** the user sets provider mode to Fixed, selects a provider, and leaves model override empty
- **THEN** transformations for this action use the provider's default model

### Requirement: Transform pipeline respects per-action provider
The transformation pipeline SHALL check the action's provider mode before selecting a provider. Fixed mode SHALL use the action's assigned provider; Active mode SHALL use the global active provider.

#### Scenario: Fixed action uses assigned provider
- **WHEN** a transformation triggers for an action with provider_mode=fixed and a valid provider_id
- **THEN** the request is sent to the assigned provider, not the global active provider

#### Scenario: Fixed action with deleted provider falls back
- **WHEN** a transformation triggers for an action whose fixed provider has been deleted
- **THEN** the action's provider_mode is reset to active AND the global active provider is used

#### Scenario: Active action uses global provider
- **WHEN** a transformation triggers for an action with provider_mode=active
- **THEN** the request is sent to the global active provider

### Requirement: History records provider used
History records SHALL capture the actual provider and model used for the transformation, reflecting any per-action override.

#### Scenario: History shows fixed provider
- **WHEN** a transformation completes using a fixed provider override
- **THEN** the history record stores the fixed provider's name and the overridden model name
