# Tasks

- [x] Wire real testConnection in ProviderInlineEditor — Replace fake runTest() with real LiveProviderService().testConnection() call, resolve API key from in-memory state, update provider model with results, add @State vars for test feedback
- [x] Wire real testConnection in DiagnosticsSettingsView — Replace fake runDiagnostics() with real call, load API key from Keychain, update provider model, display real latency
- [x] Add inline test result display in ProviderInlineEditor — Show success (green checkmark + latency) or error (red X + message) below Test Connection button
