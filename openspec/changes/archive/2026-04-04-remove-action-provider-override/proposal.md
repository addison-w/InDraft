## Why

The per-action provider override (Fixed Provider mode, provider picker, model override field) adds complexity that isn't needed at this stage. All actions should use the active provider, simplifying the UI and reducing the surface area of the Action model.

## What Changes

- **BREAKING**: Remove `providerMode`, `providerID`, and `modelOverride` fields from the Action model
- Remove the PROVIDER section from the inline action editor (ActionInlineEditor)
- Remove the provider/model override fields from the new action form
- Remove provider mode logic from TransformService (always use active provider's default model)
- Clean up related test fixtures

## Non-goals

- This does NOT change the Provider model or provider management
- This does NOT affect the global active provider selection
- No changes to window management or activation policy

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

(none — this is a removal/simplification, no spec-level behavior changes)

## Impact

- **Models**: `Action` — remove `providerMode`, `providerID`, `modelOverride` properties
- **Services**: `TransformService` — remove model override fallback logic, always use `provider.defaultModel`
- **Views**: `ActionsSettingsView` (ActionInlineEditor, new action form) — remove PROVIDER section
- **Tests**: Update test fixtures that reference removed Action properties
- **Complexity**: S (small) — straightforward property and UI removal
