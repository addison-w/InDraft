## ADDED Requirements

### Requirement: Provider data model
Each provider SHALL store: id (auto-generated), display_name (max 50 chars), base_url (HTTPS required), api_key_reference (Keychain reference), default_model, enabled, is_active, last_test_status (untested|success|failed), last_test_error, last_tested_at, created_at, updated_at.

#### Scenario: Create provider with valid fields
- **WHEN** a provider is created with display name, base URL, API key, and model
- **THEN** the provider is persisted with the API key stored in Keychain AND a reference ID stored in the database

### Requirement: Multiple provider support with single active
Users SHALL be able to configure multiple providers. Exactly one enabled provider SHALL be active at any time.

#### Scenario: Add second provider
- **WHEN** the user adds a second provider
- **THEN** both providers appear in the provider list AND only one is marked active

#### Scenario: Switch active provider
- **WHEN** the user sets a different provider as active
- **THEN** the new provider becomes active AND the previous one loses active status AND the change takes effect immediately

#### Scenario: Cannot delete active provider
- **WHEN** the user attempts to delete the active provider
- **THEN** the deletion is prevented with a message to set another provider as active first

#### Scenario: Disable active provider
- **WHEN** the active provider is disabled
- **THEN** the app enters "no active provider" state AND the menu bar shows a warning

### Requirement: Secure API key storage
API keys SHALL be stored in macOS Keychain, not in the app's database or preferences. The database SHALL only store a reference identifier.

#### Scenario: API key stored in Keychain
- **WHEN** a provider is saved with an API key
- **THEN** the API key is written to Keychain AND the database stores only a reference identifier

#### Scenario: API key masked in UI
- **WHEN** the provider editor displays an existing API key
- **THEN** the key is masked (dots) with a "Show" toggle to reveal temporarily

### Requirement: Base URL validation
Provider base URLs SHALL be validated as well-formed HTTPS URLs. HTTP URLs SHALL be rejected.

#### Scenario: Valid HTTPS URL accepted
- **WHEN** the user enters `https://api.openai.com/v1` as base URL
- **THEN** validation passes

#### Scenario: HTTP URL rejected
- **WHEN** the user enters `http://api.example.com/v1` as base URL
- **THEN** validation fails with "HTTPS is required for security"

### Requirement: Connection testing
Each provider SHALL have a "Test Connection" button that sends a minimal chat completions request to validate the configuration.

#### Scenario: Successful connection test
- **WHEN** the user clicks "Test Connection" with valid configuration
- **THEN** the app sends `POST {base_url}/chat/completions` with a simple prompt AND shows "Connected — model [model] responded in [latency]ms"

#### Scenario: Invalid API key
- **WHEN** the connection test receives a 401 response
- **THEN** the app shows "Authentication failed — check your API key"

#### Scenario: Unreachable URL
- **WHEN** the connection test cannot reach the base URL
- **THEN** the app shows "Could not reach [base_url] — check the URL"

#### Scenario: Model not found
- **WHEN** the connection test receives a model-not-found error
- **THEN** the app shows "Model [model] not available — check model name"

#### Scenario: Connection timeout
- **WHEN** the connection test takes more than 10 seconds
- **THEN** the app shows "Connection timed out"

#### Scenario: Unexpected response format
- **WHEN** the response does not match OpenAI chat completions format
- **THEN** the app shows "Unexpected response — endpoint may not be OpenAI-compatible"

### Requirement: Test results persisted
Last test result and timestamp SHALL be persisted and displayed on the provider card.

#### Scenario: Test result shown on provider card
- **WHEN** a provider has been tested
- **THEN** the provider card shows the last test status, error (if any), and timestamp

### Requirement: Active provider displayed in dropdown header
The menu bar dropdown header SHALL display the active provider's display name (not model name). If no provider is active, a warning message SHALL be shown.

#### Scenario: Active provider shown in dropdown
- **WHEN** the user opens the menu bar dropdown with an active provider configured
- **THEN** the dropdown header shows "PROVIDER" label followed by the provider's display name (e.g., "Claude", "OpenAI", "Local")

#### Scenario: No active provider warning
- **WHEN** the user opens the menu bar dropdown with no active provider
- **THEN** the dropdown header shows "No provider configured" instead of a provider name
