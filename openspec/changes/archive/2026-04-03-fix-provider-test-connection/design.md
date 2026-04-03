## Context

The `LiveProviderService.testConnection()` method already makes a real API call (sends "Reply with OK" and checks the response). However, the UI code in `ProviderInlineEditor.runTest()` and `DiagnosticsSettingsView.runDiagnostics()` never calls it — they just `Task.sleep` and hardcode `.success`. The `Provider` model already has `lastTestStatus`, `lastTestedAt`, and `lastTestError` fields ready to store results.

## Goals / Non-Goals

**Goals:**
- Wire real `LiveProviderService.testConnection()` in both Providers and Diagnostics views
- Load API key from Keychain before testing (required for the real call)
- Display success (with latency) and error (with message) inline in the UI
- Persist test results to the Provider model

**Non-Goals:**
- Modifying `ProviderServiceProtocol` or `LiveProviderService`
- Adding auto-test on provider save
- Background periodic health checks

## Decisions

### 1. Call testConnection directly from views
**Decision**: Instantiate `LiveProviderService` and `LiveKeychainService` in the view code and call `testConnection` in a `Task`.
**Rationale**: The views already create `LiveKeychainService` instances. No need for dependency injection here — these are settings screens, not frequently-tested paths. Matches existing patterns in `ProviderEditorView`.

### 2. Show inline test result feedback
**Decision**: Add `@State` properties for test result (success/failure + message) and show them below the Test Connection button using `StatusPill` for success and error text for failures.
**Rationale**: Matches existing UI patterns. No need for a toast — the result should persist visually until the next test.

### 3. Resolve API key from Keychain before testing
**Decision**: Use the existing `provider.apiKeyReference` → `keychainService.retrieve()` flow. For the new provider form, use the in-memory `apiKey` state directly.
**Rationale**: API keys are never stored on the Provider model — only a Keychain reference. Must resolve the actual key before calling `testConnection`.

## Risks / Trade-offs

- **[Network delay blocks UI]** → Test runs in a `Task` on a background thread; UI shows a spinner. The 10s timeout on `URLRequest` bounds the worst case.
- **[API key not in Keychain yet]** → For newly created providers that haven't been saved, fall back to the in-memory `apiKey` state variable.

## Testability

No new protocols needed. Existing `MockProviderService` already supports configurable `connectionTestResult`. The fix is in view-layer wiring — unit tests for `ProviderService` already cover the service logic. The new inline test result display can be verified visually.
