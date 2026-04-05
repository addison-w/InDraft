## MODIFIED Requirements

### Requirement: Multiple provider support with single active
Users SHALL be able to configure multiple providers. Exactly one enabled provider SHALL be active at any time. Providers MAY also be referenced directly by actions with fixed provider mode.

#### Scenario: Add second provider
- **WHEN** the user adds a second provider
- **THEN** both providers appear in the provider list AND only one is marked active

#### Scenario: Switch active provider
- **WHEN** the user sets a different provider as active
- **THEN** the new provider becomes active AND the previous one loses active status AND the change takes effect immediately for actions using active provider mode

#### Scenario: Cannot delete active provider
- **WHEN** the user attempts to delete the active provider
- **THEN** the deletion is prevented with a message to set another provider as active first

#### Scenario: Delete provider assigned to actions
- **WHEN** the user deletes a provider that is assigned as fixed to one or more actions
- **THEN** the provider is deleted AND all actions referencing it are reset to provider_mode=active with provider_id=nil

#### Scenario: Disable active provider
- **WHEN** the active provider is disabled
- **THEN** the app enters "no active provider" state AND the menu bar shows a warning
