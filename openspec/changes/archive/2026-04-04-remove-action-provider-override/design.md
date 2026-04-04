## Context

The Action model currently has three provider-related properties: `providerMode` (enum: `.active` / `.fixed`), `providerID` (optional UUID), and `modelOverride` (optional String). The `TransformService` checks these to determine which provider and model to use per-action. The `ActionInlineEditor` and new action form expose UI for these fields (InkSegmentPicker for provider mode, provider dropdown, model override text field).

In practice, all actions use the active provider. The per-action override adds UI complexity without current benefit.

## Goals / Non-Goals

**Goals:**
- Remove `providerMode`, `providerID`, `modelOverride` from the Action model
- Remove the PROVIDER section from ActionInlineEditor and the new action form
- Simplify TransformService to always use the active provider's default model
- Update tests to remove references to deleted properties

**Non-Goals:**
- No changes to the Provider model or provider management UI
- No changes to ProviderService protocol or implementation
- No SwiftData migration (properties will be dropped; SwiftData handles this automatically for optional/defaulted properties)

## Decisions

### 1. Remove properties from Action model directly
**Decision**: Delete the three properties rather than deprecating or hiding them.
**Rationale**: No users in production yet, no migration burden. SwiftData lightweight migration handles property removal automatically when the schema version doesn't change.
**Alternative considered**: Keep properties but hide UI — rejected because it leaves dead code.

### 2. Simplify TransformService model resolution
**Decision**: Remove the `action.modelOverride ?? provider.defaultModel` fallback chain. Always use `provider.defaultModel`.
**Rationale**: With no model override on Action, the fallback is unnecessary.
**Interfaces affected**: `TransformService.transform()` — the `model` variable assignment simplifies to `provider.defaultModel`.

### 3. Remove ProviderMode enum
**Decision**: Delete the `ProviderMode` enum entirely.
**Rationale**: Only used by the Action model's removed `providerMode` property. No other consumers.

## Testability

- Existing `TransformServiceTests` will need fixture updates (remove `providerMode`, `providerID`, `modelOverride` from Action initializers)
- Verify build succeeds with `xcodebuild -scheme InDraft build`
- Run full test suite: `xcodebuild test -scheme InDraft -destination 'platform=macOS'`

## Risks / Trade-offs

- **[Risk]** SwiftData migration failure on existing data → **Mitigation**: SwiftData handles lightweight migration for property removal. The app is pre-release, so no production data to migrate.
- **[Risk]** Future need for per-action provider override → **Mitigation**: Properties can be re-added later. The proposal and this design document the removal rationale for future reference.
