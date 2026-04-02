# InDraft — Product Requirements Document

**Product:** InDraft — macOS AI Writing Assistant
**Category:** macOS menu bar productivity app
**Platform:** macOS only (MVP)
**Last updated:** 2026-04-02

---

## 1. Executive Summary

**Product:** InDraft — a macOS menu bar utility that transforms selected text in place using AI.

**Problem:** Knowledge workers rewrite text dozens of times daily across Slack, email, docs, and browsers. The current workflow — copy, switch to AI chat, paste, prompt, copy result, switch back, paste — creates cumulative friction that breaks focus.

**Solution:** A background macOS app that captures selected text via global hotkey, sends it to an AI provider, and replaces the selection in place. No app switching. No copy-paste. One keystroke.

**MVP delivers:**

- 3 default actions (Rewrite for Clarity, Grammar Fix, Paraphrase) with global hotkeys
- Custom action creation with configurable prompts, hotkeys, and output behavior
- OpenAI-compatible provider support (BYOK) with secure API key storage
- Local transformation history with search, review, and recovery
- Accessibility-driven text capture and replacement with clipboard fallback
- Menu bar status feedback and settings UI
- Permission onboarding flow

**Success criteria:**

- Median hotkey-to-replacement latency < 2 seconds (excluding AI provider response time)
- Successful text capture and replacement rate >= 90% across top 10 macOS apps (Slack, Mail, Safari, Chrome, Notes, TextEdit, VS Code, Notion, Confluence, Pages)
- 3+ transformations per active user per day within first week
- 7-day retention >= 60%

---

## 2. Problem & Opportunity

**The problem:**
Knowledge workers frequently rewrite short-to-medium text for clarity, grammar, tone, or paraphrasing across professional tools — Slack, email, Confluence, documentation, browsers, and internal communication platforms.

**Current workflow (9 steps):**

1. Select text
2. Copy
3. Switch to browser/AI chat
4. Paste text
5. Write instruction (e.g., "rewrite for clarity")
6. Wait for response
7. Copy result
8. Return to original app
9. Paste rewritten version

**Impact:** Each instance takes 15-30 seconds. A user doing this 20+ times per day loses 5-10 minutes to mechanical overhead alone — plus the cognitive cost of context switching.

**Opportunity:** Compress the 9-step workflow to 1 step: select text, press hotkey, done. The transformation happens in place, in the app where the user is already working.

---

## 3. Target Users

**Primary:** Knowledge workers who write frequently across multiple apps daily — engineers, PMs, operators, founders, consultants.

**Ideal early adopter:**

- Writes heavily across 3+ apps daily
- Already uses AI tools for writing assistance
- Feels the friction of browser-based AI rewriting
- Prefers keyboard-driven workflows
- Willing to configure an API key

**High-frequency use cases:**

| Use Case | Example | Default Action |
|---|---|---|
| Polish a message before sending | Rough Slack message → clear, professional | Rewrite for Clarity |
| Fix grammar in a draft | Email with typos/errors → corrected | Grammar Fix |
| Rephrase for variety | Repetitive paragraph → varied wording | Paraphrase |
| Custom transformation | Chinese draft → English translation | User-created action |

---

## 4. Product Principles

1. **In-place first** — Transformations happen where the user is writing. No app switching.
2. **One-keystroke fast** — Common actions require one hotkey, zero menu navigation.
3. **Useful immediately** — Default actions work out of the box after provider setup.
4. **Customizable without complexity** — Power users can customize deeply; defaults stay simple.
5. **Local-first privacy** — Settings and history stay on device. Only selected text is sent to the user's chosen provider.
6. **Transparent state** — The user always knows if the app is ready, processing, misconfigured, or blocked.
7. **Safe failure** — When in-place replacement isn't possible, fall back gracefully. Never destroy content.

---

## 5. MVP Scope & Non-Goals

### In Scope (MVP)

- Menu bar background app
- 3 default actions with global hotkeys
- Custom action CRUD (create, edit, duplicate, delete, reorder, enable/disable)
- Accessibility-driven text capture with clipboard fallback
- In-place text replacement with clipboard fallback
- OpenAI-compatible provider support (BYOK)
- Multiple provider configurations, one active at a time
- Action-level provider/model override
- Secure API key storage (macOS Keychain)
- Provider connection testing
- Local transformation history with search and recovery
- Menu bar status indicators
- Settings UI (general, actions, providers, history, diagnostics)
- Permission onboarding flow
- Configurable output behavior per action (replace, preview, clipboard-only)

### Not in Scope (MVP)

- Full chat interface or AI assistant workspace
- Long-form document generation
- Rich text formatting preservation guarantees
- Cross-device sync
- Team/collaborative features
- Cloud-hosted history
- Prompt marketplace or community sharing
- Windows/Linux support
- Workflow automation chains
- Non-OpenAI-compatible provider types (Anthropic native, custom)
- Universal action picker (post-MVP)

---

## 6. User Flows

### Primary Flow — Hotkey-Triggered Transformation

1. User selects text in any app
2. User presses global hotkey (e.g., `Control + Option + 1`)
3. App captures selected text via Accessibility API (or clipboard fallback)
4. Menu bar icon changes to "processing" state
5. App sends text + action prompt to active provider
6. App receives transformed text
7. App replaces selected text in place (or clipboard fallback)
8. Menu bar icon shows brief "success" state
9. Transformation recorded in local history

### First-Run Onboarding Flow

1. Welcome — value proposition explanation
2. Accessibility permission — explain why needed, guide through System Settings
3. Add provider — enter name, base URL, API key, select model
4. Test connection — validate provider is reachable and key works
5. Show default actions — display 3 defaults with hotkeys
6. Run sample transformation — user tries a real rewrite
7. Setup complete

### Error/Fallback Flows

- **No text selected:** Show notification "No text selected" — no action taken
- **Text capture fails:** Show notification with error, no clipboard modification
- **Provider request fails:** Show error in menu bar + notification with cause (auth, network, timeout). Copy nothing. Log to history with error status.
- **Replacement fails:** Copy transformed text to clipboard, show notification "Result copied to clipboard — paste manually." Restore original clipboard after 30 seconds.
- **Permission missing:** Menu bar shows "permission required" state. Clicking opens diagnostics with guided fix.

---

## 7. Screen & View Inventory

Every UI surface in the app, for driving design.

| # | View | Type | Description |
|---|------|------|-------------|
| 1 | **Menu Bar Icon** | System menu bar | Persistent icon reflecting app state (idle, processing, success, error, permission needed) |
| 2 | **Menu Bar Dropdown** | Menu | Active provider, status, actions list, Open Settings, Open History, Retry Last, Quit |
| 3 | **Onboarding: Welcome** | Window | Value prop, "Get Started" CTA |
| 4 | **Onboarding: Accessibility Permission** | Window | Explanation + link to System Settings, permission status indicator |
| 5 | **Onboarding: Add Provider** | Window | Form: name, base URL, API key, model selection |
| 6 | **Onboarding: Test Connection** | Window | Test button, status indicator (testing, success, error with details) |
| 7 | **Onboarding: Default Actions** | Window | List of 3 default actions with hotkeys displayed |
| 8 | **Onboarding: Sample Transformation** | Window | Guided first-use with inline test area |
| 9 | **Onboarding: Complete** | Window | Success confirmation, "Open Settings" or dismiss |
| 10 | **Settings: General** | Tab | Launch at login, dock icon toggle, appearance, notification behavior |
| 11 | **Settings: Actions** | Tab | Action list with reorder, create/edit/duplicate/delete, restore defaults |
| 12 | **Settings: Action Editor** | Sheet/Modal | Name, prompt, hotkey recorder, output behavior, provider mode, enable toggle |
| 13 | **Settings: Providers** | Tab | Provider list, add/edit/delete, set active, test connection |
| 14 | **Settings: Provider Editor** | Sheet/Modal | Name, base URL, API key (masked), default model, enable toggle |
| 15 | **Settings: History** | Tab | Retention policy, clear history button, privacy note |
| 16 | **Settings: Diagnostics** | Tab | Accessibility status, hotkey registration status, provider connectivity, last error |
| 17 | **History Window** | Window | Searchable list of transformations, each expandable to show original vs. transformed, action, provider, model, latency, status. Actions: copy, retry, delete. Clear all button. |
| 18 | **Preview Panel** | Floating window | Shows transformed text before applying (for "preview before replace" output mode). Accept / Reject / Copy buttons. |
| 19 | **Toast Notification** | Overlay | Brief success/error feedback near cursor or menu bar |

---

## 8. Feature Requirements

### 8.1 Text Transformation Actions

Each action consists of:

- **id** (auto-generated)
- **name** (user-editable, max 50 characters)
- **prompt** (user-editable, max 2000 characters)
- **hotkey** (user-configurable global shortcut)
- **output_behavior** (`replace` | `preview` | `clipboard`)
- **provider_mode** (`active` | `fixed`)
- **provider_id** (nullable, required when provider_mode = `fixed`)
- **model_override** (nullable)
- **enabled** (boolean)
- **sort_order** (integer)
- **created_at** / **updated_at** (timestamps)

**Default actions shipped with the app:**

| Action | Default Hotkey | Default Prompt | Output Behavior |
|--------|---------------|----------------|-----------------|
| Rewrite for Clarity | `Control + Option + 1` | "Rewrite the following text to be clearer and more concise. Preserve the original meaning. Return only the rewritten text, no explanations." | Replace |
| Grammar Fix | `Control + Option + 2` | "Fix all grammar, spelling, and punctuation errors in the following text. Preserve the original meaning and tone. Return only the corrected text, no explanations." | Replace |
| Paraphrase | `Control + Option + 3` | "Paraphrase the following text while preserving its meaning. Use different wording and sentence structure. Return only the paraphrased text, no explanations." | Replace |

**Acceptance criteria:**

- [ ] App ships with 3 default actions pre-configured as above
- [ ] All default action fields (name, prompt, hotkey, output behavior, provider mode) are user-editable
- [ ] User can create a new custom action with all fields
- [ ] User can duplicate an existing action (creates copy with "(Copy)" suffix)
- [ ] User can delete any custom action (confirmation required)
- [ ] User can disable/enable any action (disabled actions do not respond to hotkeys)
- [ ] User can reorder actions via drag or move up/down
- [ ] "Restore Defaults" resets the 3 built-in actions to original values without deleting custom actions
- [ ] Action name is required and unique; prompt is required; hotkey is optional
- [ ] Action with no hotkey can still be triggered from the menu bar dropdown

### 8.2 Global Hotkeys

**Acceptance criteria:**

- [ ] Hotkeys work while any app is focused (system-wide registration)
- [ ] Each action's hotkey is independently configurable via a key recorder UI
- [ ] Conflicting hotkey detection: if a hotkey is already assigned to another action, show warning and require confirmation or change
- [ ] If system-level registration fails (conflict with another app), show clear error: "Could not register [hotkey] — it may be in use by another application"
- [ ] Hotkeys can be cleared (set to none) without deleting the action
- [ ] Hotkey changes take effect immediately without app restart

### 8.3 Text Capture

**Primary strategy:** macOS Accessibility API — read the selected text from the focused UI element.

**Fallback strategy:** Clipboard-based — save current clipboard, send `Cmd+C`, read clipboard, restore original clipboard.

**Acceptance criteria:**

- [ ] Primary (Accessibility) capture succeeds in: TextEdit, Notes, Mail, Safari, Chrome, Slack, VS Code, Notion, Pages, Confluence (browser)
- [ ] Fallback (clipboard) activates automatically when Accessibility capture returns empty or fails
- [ ] Original clipboard content is preserved and restored after clipboard-based capture within 5 seconds
- [ ] If both strategies fail, show notification "Could not read selected text" — no clipboard modification, no further action
- [ ] Empty selection (no text selected) shows notification "No text selected" — no API call made
- [ ] Capture completes within 500ms (excluding API call)

### 8.4 Text Replacement

**Primary strategy:** Write transformed text to the focused UI element via Accessibility API.

**Fallback strategy:** Clipboard-based — place transformed text on clipboard, send `Cmd+V`, then restore original clipboard.

**Acceptance criteria:**

- [ ] Primary replacement works in the same 10 apps listed in 8.3
- [ ] Fallback activates automatically when primary replacement fails
- [ ] Original clipboard is restored within 30 seconds after clipboard-based replacement
- [ ] If both strategies fail, copy result to clipboard and show notification "Result copied to clipboard — paste manually"
- [ ] Replacement does not insert duplicate text or overwrite unselected content
- [ ] Cursor position is at the end of the replaced text after successful replacement

### 8.5 Output Behavior Modes

| Mode | Behavior |
|------|----------|
| **Replace** | Replace selected text directly in place |
| **Preview** | Show Preview Panel (View #18) with transformed text. User clicks Accept to replace, Reject to cancel, or Copy to clipboard. |
| **Clipboard** | Copy result to clipboard only. Show notification "Result copied to clipboard." Original text unchanged. |

**Acceptance criteria:**

- [ ] Each action has one of 3 output behaviors, default is `replace`
- [ ] Preview panel shows original and transformed text side by side
- [ ] Preview panel Accept triggers the same replacement logic as direct replace
- [ ] Preview panel Reject dismisses the panel with no changes
- [ ] Clipboard mode does not modify the original text in the source app

### 8.6 Status Feedback

**Menu bar icon states:**

| State | Visual | Duration |
|-------|--------|----------|
| Idle/Ready | Default icon | Persistent |
| Processing | Animated icon (e.g., spinner overlay) | Until complete |
| Success | Checkmark overlay | 3 seconds, then return to idle |
| Error | Error overlay (e.g., red dot) | Until next action or 10 seconds |
| Permission Required | Warning overlay | Persistent until resolved |

**Toast notifications:**

- Success: "Text replaced" (auto-dismiss after 2 seconds)
- Error: "[Error cause]" with brief description (auto-dismiss after 5 seconds)
- Fallback: "Result copied to clipboard — paste manually" (auto-dismiss after 5 seconds)

**Acceptance criteria:**

- [ ] Menu bar icon reflects current state accurately and transitions within 200ms
- [ ] Toast notifications appear near the menu bar icon
- [ ] Toasts do not steal focus from the user's active app
- [ ] Error toasts include actionable information (e.g., "API key invalid — check Settings > Providers")
- [ ] Multiple rapid actions queue correctly; icon reflects the most recent state

### 8.6a Retry Last Action

The menu bar dropdown includes a "Retry Last" item that re-runs the most recent transformation on the current selection.

**Acceptance criteria:**

- [ ] "Retry Last" appears in the menu bar dropdown when at least one history record exists
- [ ] Clicking "Retry Last" runs the same action (same prompt, same provider/model) on the currently selected text
- [ ] If no text is currently selected, shows "No text selected" notification
- [ ] If the original action has been deleted, the retry still works using the snapshot data from the history record
- [ ] "Retry Last" is disabled (greyed out) when history is empty

### 8.7 History

Each history record stores:

- **id**, **timestamp**, **source_app** (name of frontmost app)
- **action_id**, **action_name**, **provider_id**, **provider_name**, **model_name**
- **original_text**, **transformed_text**
- **latency_ms** (time from hotkey to replacement complete)
- **status** (`success` | `error`)
- **error_code**, **error_message** (nullable)

**Acceptance criteria:**

- [ ] Every transformation attempt (success and failure) is recorded
- [ ] History window (View #17) shows records in reverse chronological order
- [ ] Search filters across action name, source app, original text, and transformed text
- [ ] Each record expands to show full original vs. transformed text
- [ ] User can copy original text, copy transformed text, or retry (re-run same action on original text)
- [ ] User can delete individual records
- [ ] User can clear all history (confirmation required)
- [ ] Default retention: 30 days. Configurable in Settings: 7, 30, 90 days, or unlimited.
- [ ] Records older than retention period are auto-deleted on app launch

---

## 9. AI Provider Management

### 9.1 Provider Configuration

Each provider stores:

- **id** (auto-generated)
- **display_name** (user-editable, max 50 characters)
- **base_url** (required, e.g., `https://api.openai.com/v1`)
- **api_key_reference** (stored in macOS Keychain, not in app database)
- **default_model** (string, e.g., `gpt-4o`)
- **enabled** (boolean)
- **is_active** (boolean, exactly one provider is active at a time)
- **last_test_status** (`untested` | `success` | `failed`)
- **last_test_error** (nullable string)
- **last_tested_at** (nullable timestamp)
- **created_at** / **updated_at** (timestamps)

All providers use the OpenAI-compatible chat completions API format (`POST /chat/completions`).

**Acceptance criteria:**

- [ ] User can add multiple providers
- [ ] User can edit all fields of an existing provider
- [ ] User can delete a provider (confirmation required; cannot delete the active provider)
- [ ] User can enable/disable a provider (disabled provider cannot be set as active)
- [ ] Exactly one enabled provider is active at any time
- [ ] Switching active provider takes effect immediately for all actions using `active` provider mode
- [ ] API key is stored in macOS Keychain, not in app's local database or preferences
- [ ] API key field is masked in UI; "Show" toggle reveals temporarily
- [ ] Base URL is validated as a well-formed HTTPS URL on save

### 9.2 Active Provider

- The active provider is the global default for all actions using `provider_mode = active`
- Actions with `provider_mode = fixed` use their assigned provider regardless of active selection
- The menu bar dropdown displays the current active provider name
- If the active provider becomes disabled or deleted, the app enters a "no active provider" state and shows a warning in the menu bar

**Acceptance criteria:**

- [ ] Active provider name visible in menu bar dropdown
- [ ] Changing active provider does not require app restart
- [ ] If no active provider is set, hotkey-triggered actions using `active` mode show error: "No active provider — configure one in Settings > Providers"

### 9.3 Connection Testing

The test sends a minimal chat completions request to the provider's base URL with the configured API key and model.

**Test request:** `POST {base_url}/chat/completions` with a simple prompt (e.g., "Reply with OK").

**Acceptance criteria:**

- [ ] "Test Connection" button available on each provider in the provider list and in the provider editor
- [ ] Test shows a loading state while in progress
- [ ] Success: shows green checkmark with "Connected — model [model_name] responded in [latency]ms"
- [ ] Failure cases show specific errors:
  - Invalid API key → "Authentication failed — check your API key"
  - Invalid base URL / unreachable → "Could not reach [base_url] — check the URL"
  - Model not found → "Model [model_name] not available — check model name"
  - Timeout (> 10 seconds) → "Connection timed out"
  - Unexpected response format → "Unexpected response — endpoint may not be OpenAI-compatible"
- [ ] Last test result and timestamp are persisted and displayed on the provider card

---

## 10. Permissions & Onboarding

### 10.1 Required Permissions

| Permission | Purpose | How to Grant |
|---|---|---|
| Accessibility | Read selected text, inspect focused elements, replace text | System Settings > Privacy & Security > Accessibility |

This is the only system permission required for MVP.

### 10.2 Onboarding Flow

The onboarding flow launches automatically on first run, and is re-accessible from Settings > Diagnostics.

| Step | View | Required to Proceed | Skip Allowed |
|---|---|---|---|
| 1. Welcome | Onboarding: Welcome (#3) | No | N/A |
| 2. Accessibility Permission | Onboarding: Accessibility (#4) | Yes — permission must be granted | No |
| 3. Add Provider | Onboarding: Add Provider (#5) | Yes — at least one provider configured | No |
| 4. Test Connection | Onboarding: Test Connection (#6) | Yes — test must pass | No |
| 5. Default Actions | Onboarding: Default Actions (#7) | No | Yes |
| 6. Sample Transformation | Onboarding: Sample (#8) | No | Yes |
| 7. Complete | Onboarding: Complete (#9) | No | N/A |

**Acceptance criteria:**

- [ ] Onboarding launches automatically on first app run
- [ ] User cannot skip steps 2-4 (permission + provider are prerequisites)
- [ ] Step 2 shows real-time permission status — updates when user grants in System Settings without requiring app restart
- [ ] Step 3 pre-fills base URL with `https://api.openai.com/v1` as the default
- [ ] Step 4 blocks progression until test passes; shows specific error on failure
- [ ] Steps 5-6 are skippable but encouraged
- [ ] Step 6 provides a text area with sample text and a "Try It" button that runs Rewrite for Clarity
- [ ] Completing onboarding sets the configured provider as active
- [ ] If the user quits during onboarding, app resumes at the incomplete step on next launch

### 10.3 Incomplete Setup Handling

If the app launches with incomplete setup, the menu bar icon enters a warning state and the dropdown shows what's missing:

| Missing | Menu Bar State | Dropdown Message |
|---|---|---|
| Accessibility permission | Warning icon | "Accessibility permission required — click to fix" |
| No provider configured | Warning icon | "No AI provider configured — click to set up" |
| Active provider invalid (disabled/deleted) | Warning icon | "No active provider — click to select one" |
| Active provider test failed | Error icon | "Provider connection failed — click to check" |

**Acceptance criteria:**

- [ ] Each missing-state message in the dropdown links directly to the relevant settings tab or onboarding step
- [ ] Hotkey presses while setup is incomplete show a notification explaining what's missing rather than failing silently

---

## 11. Data Model

```
┌─────────────┐       ┌─────────────────┐       ┌──────────────────┐
│   Action     │       │    Provider      │       │  HistoryRecord   │
├─────────────┤       ├─────────────────┤       ├──────────────────┤
│ id           │       │ id               │       │ id                │
│ name         │       │ display_name     │       │ timestamp         │
│ prompt       │  ┌───▶│ base_url         │◀──┐   │ source_app        │
│ hotkey       │  │    │ api_key_reference │   │   │ action_id ────────┼──▶ Action
│ output_behav │  │    │ default_model    │   │   │ action_name       │
│ provider_mode│  │    │ enabled          │   │   │ provider_id ──────┼──▶ Provider
│ provider_id ─┼──┘    │ is_active        │   │   │ provider_name     │
│ model_overrid│       │ last_test_status │   │   │ model_name        │
│ enabled      │       │ last_test_error  │   │   │ original_text     │
│ sort_order   │       │ last_tested_at   │   │   │ transformed_text  │
│ created_at   │       │ created_at       │   │   │ latency_ms        │
│ updated_at   │       │ updated_at       │   │   │ status            │
└─────────────┘       └─────────────────┘   │   │ error_code        │
                                              └───│ error_message     │
                                                  └──────────────────┘
```

**Storage:**

- Actions and Providers: local database (SQLite or SwiftData)
- API keys: macOS Keychain (referenced by `api_key_reference`)
- History records: same local database
- Settings/preferences: UserDefaults

**Acceptance criteria:**

- [ ] Action.provider_id is nullable — null means "use active provider"
- [ ] Provider.is_active is true for exactly one provider at all times (enforced at app level)
- [ ] HistoryRecord stores action_name and provider_name as snapshots (not just foreign keys) so history remains readable if actions/providers are deleted
- [ ] Deleting a provider nullifies Action.provider_id for any action referencing it and switches those actions to `provider_mode = active`
- [ ] Deleting an action does not delete its history records

---

## 12. Reliability & Fallback Behavior

The app operates across a wide variety of macOS apps and editors. Not all will support Accessibility API access equally.

**Strategy priority chain:**

| Priority | Capture Method | Replacement Method | When Used |
|---|---|---|---|
| 1 | Accessibility API | Accessibility API | App supports AX read + write on focused element |
| 2 | Clipboard (Cmd+C) | Clipboard (Cmd+V) | AX read or write fails/unavailable |
| 3 | — | Copy to clipboard only | Both replacement methods fail |
| 4 | — | — | Both capture methods fail — abort with notification |

**Timing constraints:**

- Clipboard save/restore cycle must complete within 5 seconds
- If clipboard fallback is used, original clipboard is restored after 30 seconds
- Total capture + replacement overhead (excluding AI response) must be < 1 second

**Acceptance criteria:**

- [ ] Fallback from priority 1 → 2 is automatic with no user intervention
- [ ] Fallback from priority 2 → 3 shows notification "Result copied to clipboard — paste manually"
- [ ] Priority 4 (total failure) shows notification "Could not read selected text" with no side effects
- [ ] The app never overwrites unselected content
- [ ] The app never leaves the clipboard in a modified state for more than 30 seconds after a clipboard-based operation
- [ ] Failed transformations are logged to history with status `error` and the specific failure point (capture, API, replacement)

---

## 13. Privacy & Data Handling

**Privacy model:** Local-first. No data leaves the device except selected text sent to the user's configured provider.

| Data | Storage Location | Sent Externally |
|---|---|---|
| Selected text | Transient (memory only) | Yes — to configured AI provider |
| Transformed text | Local database (history) | No |
| Original text | Local database (history) | No |
| API keys | macOS Keychain | Yes — as auth header to provider |
| Action configs | Local database | No |
| Provider configs | Local database (key reference only) | No |
| App preferences | UserDefaults | No |

**Acceptance criteria:**

- [ ] No telemetry, analytics, or crash reporting that transmits user text in MVP
- [ ] Settings UI includes a privacy note in the History tab: "All history is stored locally on this device. Selected text is sent only to your configured AI provider for processing."
- [ ] User can disable history recording entirely in Settings > History
- [ ] User can clear all history with one action (confirmation required)
- [ ] No network requests are made except to the user's configured provider base URL
- [ ] API requests use HTTPS only (HTTP base URLs are rejected at validation)

---

## 14. Success Metrics

### Primary Metrics

| Metric | Target | How Measured |
|---|---|---|
| Median hotkey-to-replacement latency | < 2s (excluding provider response) | Local timing in history records |
| Successful transformation rate | >= 90% across top 10 apps | History status field |
| Transformations per active user per day | >= 3 within first week | History record count |
| 7-day retention | >= 60% | App launch tracking (local) |
| 30-day retention | >= 40% | App launch tracking (local) |

### Quality Metrics

| Metric | Signal | Source |
|---|---|---|
| Failure rate by cause | Permission, unsupported editor, API, replacement | History error_code breakdown |
| Hotkey registration failure rate | < 2% of configured hotkeys | Diagnostics log |
| Clipboard fallback rate | Track how often fallback is used vs. primary | Internal counter |
| Provider test success rate | >= 95% for correctly configured providers | Provider test results |

### Product-Market Fit Signals

- Users trigger 5+ transformations per day
- Users create custom actions beyond the 3 defaults
- Users report reduced context switching in feedback
- Users are willing to pay in BYOK mode (no bundled AI cost)

**Acceptance criteria:**

- [ ] All latency, status, and error data needed for these metrics is captured in the history record schema
- [ ] App tracks daily active usage locally (date of last use) for retention calculation — no external transmission
- [ ] Clipboard fallback usage is counted and accessible in Settings > Diagnostics

---

## 15. Risks & Open Questions

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Accessibility API inconsistency across apps | High | Medium | Clipboard fallback chain; test against top 10 apps; log which apps use fallback |
| Rich text editors lose formatting on replacement | Medium | Low | MVP targets plain text replacement only; document as known limitation |
| Global hotkey conflicts with other apps | Medium | Low | Detect registration failures; show clear error; allow user to change hotkey |
| Clipboard fallback race conditions | Medium | High | Queue operations; enforce timing constraints; never leave clipboard modified > 30s |
| macOS permission changes in future OS versions | Low | High | Abstract permission checks; monitor macOS betas |

### Product Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| BYOK setup friction reduces adoption | Medium | High | Streamlined onboarding; pre-fill OpenAI defaults; clear error messages |
| Users expect formatting preservation | Medium | Medium | Document plain-text-only limitation; consider post-MVP rich text support |
| Users don't discover custom actions | Low | Low | Onboarding step shows defaults; menu bar dropdown lists all actions |

### Open Questions

| Question | Default Assumption | Revisit When |
|---|---|---|
| Default history retention period? | 30 days | After user feedback on storage size |
| Should failed transformations be stored in history? | Yes — aids debugging | If storage becomes a concern |
| Should the universal action picker be in MVP? | No — post-MVP | If user testing shows hotkey memorization is a barrier |
| Should "Translate to English" be a 4th default action? | No — keep to 3 | If early adopters frequently create this action manually |
| Local database: SQLite vs SwiftData? | SwiftData (native, simpler) | During technical planning |

---

## 16. Post-MVP Opportunities

Ordered by estimated user value:

| Priority | Feature | Description |
|---|---|---|
| P1 | Universal action picker | Hotkey opens a small palette listing all actions — no need to memorize shortcuts |
| P1 | Undo last replacement | Dedicated hotkey to restore original text from the most recent transformation |
| P2 | Inline preview / diff view | Show original vs. transformed text side-by-side before accepting |
| P2 | Non-OpenAI provider types | Native Anthropic, Google, local model support |
| P2 | Per-app behavior customization | Different default actions or output behaviors per source app |
| P3 | Tone presets and style libraries | Pre-built prompt packs (professional, casual, academic) |
| P3 | Prompt variables / templates | Dynamic prompts with placeholders like `{language}` or `{tone}` |
| P3 | Export/import actions | Share action configurations as JSON files |
| P3 | Usage analytics dashboard | Local dashboard showing transformation frequency, latency trends, failure rates |
| P4 | Cross-device sync | Sync actions and preferences via iCloud |
| P4 | Team-shared prompt packs | Shared action libraries for teams |
| P4 | Hosted AI option | Bundled AI usage without BYOK |
