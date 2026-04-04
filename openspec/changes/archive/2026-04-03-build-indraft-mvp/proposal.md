## Why

Knowledge workers rewrite text dozens of times daily across Slack, email, docs, and browsers. The current 9-step workflow (copy, switch to AI chat, paste, prompt, copy result, switch back, paste) creates cumulative friction that breaks focus. InDraft compresses this to one step: select text, press hotkey, done. The transformation happens in place, in the app where the user is already working.

This is the initial MVP build — no existing codebase. We are building a native macOS menu bar app from scratch.

## What Changes

- New macOS menu bar application (Swift/SwiftUI) with background daemon architecture
- Global hotkey system for triggering text transformation actions system-wide
- Accessibility API integration for in-place text capture and replacement with clipboard fallback chain
- OpenAI-compatible AI provider management with BYOK (bring your own key) model
- Local transformation history with search, review, and recovery
- Multi-step onboarding flow for permissions, provider setup, and first-use guidance
- Settings UI with tabs for General, Actions, Providers, History, and Diagnostics
- Action CRUD system with configurable prompts, hotkeys, output behavior, and provider overrides
- Preview panel for reviewing transformations before accepting
- Secure API key storage via macOS Keychain
- Menu bar status feedback (idle, processing, success, error, permission-required states)
- Toast notification system for non-intrusive user feedback

## Capabilities

### New Capabilities
- `app-core`: macOS app lifecycle, menu bar presence, launch-at-login, dock icon toggle, and harness architecture for long-running background operation
- `text-capture-replace`: Accessibility API text capture and replacement with clipboard fallback chain, ensuring safe operation across top 10 macOS apps
- `hotkey-system`: Global hotkey registration, conflict detection, key recorder UI, and system-wide action triggering
- `actions-engine`: Action data model, CRUD operations, default actions, reordering, enable/disable, output behavior modes (replace/preview/clipboard), and prompt execution
- `provider-management`: AI provider configuration, BYOK API key storage in Keychain, active provider switching, connection testing, and OpenAI-compatible API integration
- `transformation-history`: Local history storage, search, retention policies, individual record management, and recovery/retry functionality
- `onboarding-flow`: Multi-step first-run experience covering permissions, provider setup, connection testing, default actions overview, and sample transformation
- `settings-ui`: Tabbed settings window (General, Actions, Providers, History, Diagnostics) with all configuration surfaces
- `preview-panel`: Floating window showing original vs. transformed text with accept/reject/copy actions
- `status-feedback`: Menu bar icon state machine, toast notifications, error reporting, and diagnostic information display

### Modified Capabilities
<!-- No existing capabilities — this is a greenfield build -->

## Impact

- **New Xcode project**: Swift 5.9+, SwiftUI, targeting macOS 14+ (Sonoma)
- **System APIs**: Accessibility API (AXUIElement), Carbon hotkey registration (or modern equivalent), NSPasteboard, Keychain Services
- **Dependencies**: Minimal — prefer system frameworks. OpenAI-compatible HTTP client built on URLSession.
- **Privacy**: Accessibility permission required. No telemetry. Only selected text sent to user's chosen provider over HTTPS.
- **Storage**: SwiftData for actions, providers, history. UserDefaults for preferences. Keychain for API keys.
- **Architecture**: Follows harness engineering principles — generator/evaluator separation for long-running operations, structured context handoffs between components, feature-based modular design with clear boundaries.
