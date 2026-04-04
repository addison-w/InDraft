## Why

The "Test Connection" button in both the Providers settings and Diagnostics screen is hardcoded to always return success after a fake delay. It never actually calls `ProviderService.testConnection()` with the real URL, API key, and model. Users have no way to verify their provider configuration works, and no error feedback when it doesn't.

## What Changes

- Wire up the real `LiveProviderService.testConnection()` in both `ProvidersSettingsView` (inline editor) and `DiagnosticsSettingsView`
- Load the actual API key from Keychain before testing (currently not done)
- Display test results in the UI: success with latency, or error message
- Show inline test status feedback (success/error) that persists until the next test or edit

## Non-goals

- Changing the `ProviderService` protocol or implementation (it already works correctly)
- Adding retry logic or automatic periodic testing
- Changing the test prompt ("Reply with OK")

## Capabilities

### New Capabilities
- `provider-test-feedback`: UI feedback for provider connection test results (success with latency, error with message)

### Modified Capabilities
- `provider-management`: Wire real `testConnection()` calls instead of fake success

## Impact

- **Services affected**: None — `LiveProviderService.testConnection()` already works
- **Views affected**: `ProviderInlineEditor` (in ProvidersSettingsView), `DiagnosticsSettingsView`
- **Models affected**: `Provider` — already has `lastTestStatus`, `lastTestedAt`, `lastTestError` fields
- **Dependencies**: `KeychainService` — needed to load API key for testing

## Complexity

**S** — The service layer is already correct. This is purely a UI wiring fix.
