## Context

`ProviderService.buildRequest()` hardcodes `request.timeoutInterval = 10`. The `Provider` model has no timeout field. The `ProviderServiceProtocol` methods (`transform`, `testConnection`) don't accept a timeout parameter — they'd need one added, or the service needs to accept it at call sites.

## Goals / Non-Goals

**Goals:**
- Add `timeoutSeconds: Int` to Provider model with default 30
- Thread timeout through to URLRequest in ProviderService
- Add slider UI (10–180s) in provider inline editor
- Minimalist slider design following existing editorial aesthetic

**Non-Goals:**
- Changing the ProviderServiceProtocol signature (keep it simple — pass timeout as parameter)
- Per-action timeout overrides

## Decisions

### 1. Add timeout as a parameter to protocol methods
**Decision**: Add `timeout: TimeInterval` parameter to both `transform()` and `testConnection()` in `ProviderServiceProtocol`.
**Rationale**: Clean — the caller (TransformService, views) already has access to the Provider model and can pass `provider.timeoutSeconds`. Keeps the service stateless.
**Alternative considered**: Storing timeout on the service instance — rejected because the service is shared and providers have different timeouts.

### 2. Default 30s, range 10–180
**Decision**: `timeoutSeconds` defaults to 30. Slider range 10–180 with step of 5.
**Rationale**: 30s is generous for most providers. 10s minimum prevents accidental near-zero values. 180s maximum covers very slow self-hosted models. Step of 5 keeps the slider clean.

### 3. Slider with value label
**Decision**: Use a SwiftUI `Slider` with a trailing label showing "{N}s". No separate text field.
**Rationale**: Minimalist — one control, clear feedback. Step of 5 means 35 discrete positions, easily navigable.

## Risks / Trade-offs

- **[SwiftData migration]** → Adding a new stored property with a default value. SwiftData handles lightweight migrations automatically for new fields with defaults. No manual migration needed.
- **[Protocol change breaks tests]** → `MockProviderService` needs updating to match new signatures. Straightforward — add the parameter with a default value.

## Testability

- `ProviderTests`: verify default `timeoutSeconds` is 30
- `ProviderServiceTests`: verify timeout is passed to URLRequest (check mock URLSession)
- `MockProviderService`: update to accept new parameter
