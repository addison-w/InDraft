## Why

The request timeout is hardcoded to 10 seconds in `ProviderService.buildRequest()`. Some providers (especially self-hosted or slower models) need more time. Users should be able to configure timeout per provider, with a sensible default of 30 seconds.

## What Changes

- Add a `timeoutSeconds` field to the `Provider` model (default: 30, range: 10–180)
- Pass the provider's timeout to `ProviderService` when building requests
- Add a slider in the provider inline editor UI for adjusting timeout
- Display the current value with a label showing seconds

## Non-goals

- Per-action timeout overrides
- Automatic timeout adjustment based on latency history
- Retry logic on timeout

## Capabilities

### New Capabilities
- `provider-timeout`: Configurable per-provider request timeout with slider UI

### Modified Capabilities
- `provider-management`: Add timeout field to Provider model and wire through to API calls

## Impact

- **Model**: `Provider` — new `timeoutSeconds: Int` field (SwiftData migration auto-handled)
- **Service**: `ProviderService.buildRequest()` — accept timeout parameter instead of hardcoded 10s
- **Service**: `ProviderService.transform()` and `testConnection()` — pass timeout through
- **Views**: `ProviderInlineEditor`, new provider form — add slider
- **Tests**: Update `ProviderServiceTests` and `ProviderTests` for new field

## Complexity

**S** — One new model field, one service parameter, one UI slider.
