# Tasks

- [x] Add timeoutSeconds field to Provider model — Add `var timeoutSeconds: Int` with default 30 to Provider @Model class and init
- [x] Thread timeout through ProviderServiceProtocol — Add `timeout: TimeInterval` parameter to `transform()` and `testConnection()` in protocol, LiveProviderService, and MockProviderService. Replace hardcoded `request.timeoutInterval = 10` with the parameter.
- [x] Update all call sites to pass timeout — TransformService, ProvidersSettingsView (test connection), DiagnosticsSettingsView (diagnostics test), OnboardingContainerView (test step)
- [x] Add timeout slider to ProviderInlineEditor — Minimalist slider (10–180, step 5) with trailing "{N}s" label in the expanded provider editor
- [x] Add timeout slider to new provider form — Same slider in the inline new provider creation form with default 30
- [x] Update tests — ProviderTests (default value), ProviderServiceTests (timeout parameter), MockProviderService (new signature)
