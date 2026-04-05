## MODIFIED Requirements

### Requirement: Action data model
Each action SHALL store: id (auto-generated), name (max 50 chars), prompt (max 2000 chars), hotkey, output_behavior (replace|preview|clipboard), provider_mode (active|fixed), provider_id (nullable), model_override (nullable), enabled (boolean), sort_order (integer), created_at, updated_at.

#### Scenario: Create action with all fields
- **WHEN** a new action is created with name, prompt, and output behavior
- **THEN** the action is persisted with auto-generated id, timestamps, enabled=true, provider_mode=active, provider_id=nil, model_override=nil, and sort_order appended to end

### Requirement: Action provider mode
Each action SHALL support two provider modes: "active" (uses the global active provider) and "fixed" (uses a specific assigned provider). When provider_mode is "fixed", a provider_id and optional model_override SHALL be stored.

#### Scenario: Action uses active provider
- **WHEN** a transformation triggers for an action with provider_mode=active
- **THEN** the request is sent to the currently active global provider using that provider's default model

#### Scenario: Action uses fixed provider
- **WHEN** a transformation triggers for an action with provider_mode=fixed
- **THEN** the request is sent to the action's assigned provider regardless of the active provider

#### Scenario: Action uses fixed provider with model override
- **WHEN** a transformation triggers for an action with provider_mode=fixed AND model_override is set
- **THEN** the request is sent to the action's assigned provider using the overridden model instead of the provider's default

#### Scenario: Fixed provider deleted
- **WHEN** a provider is deleted that was assigned to an action as fixed
- **THEN** the action's provider_id is set to nil AND provider_mode is switched to active
