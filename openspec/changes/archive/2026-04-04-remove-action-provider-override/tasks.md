## 1. Model Changes

- [x] 1.1 Remove `providerMode`, `providerID`, `modelOverride` properties from the Action model
- [x] 1.2 Remove the `ProviderMode` enum
- [x] 1.3 Remove provider-related parameters from Action initializer

## 2. Service Changes

- [x] 2.1 Simplify TransformService to always use `provider.defaultModel` (remove model override fallback)

## 3. UI Changes

- [x] 3.1 Remove PROVIDER section from ActionInlineEditor (provider mode picker, provider dropdown, model override field)
- [x] 3.2 Remove provider-related state variables and fields from the new action form
- [x] 3.3 Remove the unused ActionEditorView modal (if still present)

## 4. Test Updates

- [x] 4.1 Update TransformServiceTests fixtures to remove provider override properties
- [x] 4.2 Update any other test fixtures referencing removed Action properties
- [x] 4.3 Verify full build succeeds: `xcodebuild -scheme InDraft build`
- [x] 4.4 Verify tests pass: `xcodebuild test -scheme InDraft -destination 'platform=macOS'`
