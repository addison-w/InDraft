## ADDED Requirements

### Requirement: Provider editor stores API keys in Keychain
The Settings provider editor SHALL store API keys in the macOS Keychain using a generated reference ID, matching the behavior of the onboarding flow. The `apiKeyReference` field on the Provider model SHALL always contain a Keychain reference ID, never the raw API key.

#### Scenario: New provider created from Settings stores key in Keychain
- **WHEN** the user creates a new provider in Settings > Providers
- **AND** enters an API key
- **THEN** the app SHALL generate a unique reference ID (e.g., `"provider-<UUID>"`)
- **AND** store the API key in the Keychain under that reference ID via `KeychainService.store(apiKey:forReference:)`
- **AND** set `provider.apiKeyReference` to the reference ID (not the raw key)

#### Scenario: Existing provider API key updated from Settings
- **WHEN** the user edits an existing provider and changes the API key
- **THEN** the app SHALL update the Keychain entry using `KeychainService.update(apiKey:forReference:)` with the existing `apiKeyReference`
- **AND** the `apiKeyReference` field SHALL remain the Keychain reference ID

#### Scenario: Provider editor loads API key from Keychain for display
- **WHEN** the user opens the provider editor for an existing provider
- **THEN** the app SHALL retrieve the actual API key from the Keychain using `KeychainService.retrieve(forReference:)`
- **AND** display the retrieved key (masked) in the API key field
- **AND** SHALL NOT display the Keychain reference ID to the user

#### Scenario: Hotkey triggers transformation with Keychain-stored API key
- **WHEN** a hotkey is pressed for an action with a configured provider
- **AND** the provider's API key was stored via Settings (not just onboarding)
- **THEN** `AppCoordinator` SHALL successfully retrieve the API key from the Keychain using `provider.apiKeyReference`
- **AND** the transformation SHALL proceed without "API key not found" error

### Requirement: Provider deletion cleans up Keychain entry
When a provider is deleted, its corresponding Keychain entry SHALL be removed.

#### Scenario: Delete provider removes Keychain entry
- **WHEN** the user deletes a provider from Settings
- **THEN** the app SHALL call `KeychainService.delete(forReference:)` with the provider's `apiKeyReference`
- **AND** the Keychain entry SHALL be removed

### Requirement: API key field masking in provider editor
The API key field in the provider editor SHALL be masked by default for security, with a toggle to reveal temporarily.

#### Scenario: API key masked by default
- **WHEN** the user opens the provider editor
- **THEN** the API key field SHALL display the key as masked characters (e.g., dots or asterisks)

#### Scenario: API key revealed on toggle
- **WHEN** the user clicks the "Show" toggle on the API key field
- **THEN** the actual API key text SHALL be visible
- **AND** the toggle label SHALL change to "Hide"
