# Provider Test Feedback

## Scenarios

### Test connection with valid credentials
- **GIVEN** a provider with a valid base URL, API key, and model
- **WHEN** the user taps "Test Connection"
- **THEN** the button shows a loading spinner
- **AND** `LiveProviderService.testConnection()` is called with the provider's base URL, resolved API key, and model
- **AND** on success, the provider's `lastTestStatus` is set to `.success`
- **AND** `lastTestedAt` is set to the current date
- **AND** `lastTestError` is cleared
- **AND** the UI shows a success indicator with latency (e.g., "Connected — 234ms")

### Test connection with invalid API key
- **GIVEN** a provider with an invalid API key
- **WHEN** the user taps "Test Connection"
- **THEN** `LiveProviderService.testConnection()` returns `.failure`
- **AND** the provider's `lastTestStatus` is set to `.failed`
- **AND** `lastTestError` is set to the error message
- **AND** the UI shows the error message inline (e.g., "Authentication failed — check your API key")

### Test connection with unreachable URL
- **GIVEN** a provider with an unreachable base URL
- **WHEN** the user taps "Test Connection"
- **THEN** the UI shows the error message (e.g., "Could not reach https://bad.url — check the URL")

### Test connection resolves API key from Keychain
- **GIVEN** a saved provider with an `apiKeyReference` pointing to a Keychain entry
- **WHEN** the user taps "Test Connection"
- **THEN** the API key is loaded from Keychain using `keychainService.retrieve(forReference:)`
- **AND** the resolved key is passed to `testConnection()`

### Test connection in Diagnostics view
- **GIVEN** an active provider exists
- **WHEN** the user taps "Test Now" in Diagnostics
- **THEN** the real `testConnection()` is called for the active provider
- **AND** results are displayed with the same success/error feedback

### Test button disabled during test
- **GIVEN** a test is currently in progress
- **WHEN** the user views the Test Connection button
- **THEN** the button is disabled and shows a spinner
