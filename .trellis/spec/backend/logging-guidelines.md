# Logging Guidelines

> How logging is done in this project.

---

## Overview

InDraft uses Apple's unified logging system (`os.Logger`) for all logging. No `print()`, no third-party logging libraries.

---

## Logger Setup

Define loggers as static constants per subsystem category:

```swift
import os

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.indraft"

    static let transformation = Logger(subsystem: subsystem, category: "transformation")
    static let provider = Logger(subsystem: subsystem, category: "provider")
    static let keychain = Logger(subsystem: subsystem, category: "keychain")
    static let hotkey = Logger(subsystem: subsystem, category: "hotkey")
    static let accessibility = Logger(subsystem: subsystem, category: "accessibility")
    static let clipboard = Logger(subsystem: subsystem, category: "clipboard")
    static let history = Logger(subsystem: subsystem, category: "history")
    static let app = Logger(subsystem: subsystem, category: "app")
}
```

---

## Log Levels

| Level | When to Use | Example |
|-------|------------|---------|
| `.debug` | Detailed flow tracing (development only) | `Logger.transformation.debug("Capture strategy: accessibility")` |
| `.info` | Normal operations worth noting | `Logger.transformation.info("Transformation completed in \(latency)ms")` |
| `.notice` | Significant state changes | `Logger.provider.notice("Active provider changed to \(name)")` |
| `.error` | Recoverable errors | `Logger.provider.error("Connection test failed: \(error)")` |
| `.fault` | Unexpected states that indicate a bug | `Logger.keychain.fault("Keychain returned unexpected status: \(status)")` |

### Rules
- **`.debug`** is stripped from release builds by the OS — safe for verbose output
- **`.info`** is the baseline for production-visible logs
- **`.error`** for expected failure paths (network timeout, invalid input)
- **`.fault`** only for "this should never happen" conditions

---

## What to Log

### Always log
- Transformation lifecycle: start, capture method used, API call, replacement method used, completion/failure
- Provider configuration changes: added, edited, deleted, active switched
- Hotkey registration: success, failure, conflict
- Permission status changes: accessibility granted/revoked
- App lifecycle: launch, onboarding state, first-run detection

### Log with context

```swift
Logger.transformation.info("""
    Transformation complete: \
    action=\(action.name, privacy: .public), \
    provider=\(provider.displayName, privacy: .public), \
    latency=\(latencyMs)ms, \
    captureMethod=\(captureMethod, privacy: .public), \
    replacementMethod=\(replacementMethod, privacy: .public)
    """)
```

---

## What NOT to Log

| Data | Why | Alternative |
|------|-----|-------------|
| API keys | Security — never expose secrets | Log `apiKeyReference` (the Keychain identifier) |
| Selected text content | Privacy — user's writing is sensitive | Log text length: `textLength=\(text.count)` |
| Transformed text content | Privacy | Log text length |
| Full HTTP response bodies | Verbose, may contain user data | Log status code and content length |
| Clipboard contents | Privacy | Log "clipboard saved/restored" events only |

### Privacy annotations

Use `os.Logger` privacy controls:

```swift
// Public metadata — visible in Console.app
Logger.provider.info("Testing provider: \(provider.displayName, privacy: .public)")

// Private content — redacted in release, visible in debug
Logger.transformation.debug("Captured text: \(text, privacy: .private)")

// Default (auto) — redacted for dynamic strings
Logger.keychain.error("Keychain error: \(error)")
```

---

## Structured Log Pattern

For the transformation pipeline (the critical path), use consistent key=value format:

```swift
Logger.transformation.info("transform_start: action=\(actionName, privacy: .public) app=\(sourceApp, privacy: .public)")
Logger.transformation.info("transform_capture: method=\(method, privacy: .public) textLength=\(length)")
Logger.transformation.info("transform_api: provider=\(providerName, privacy: .public) model=\(model, privacy: .public)")
Logger.transformation.info("transform_replace: method=\(method, privacy: .public)")
Logger.transformation.info("transform_complete: latencyMs=\(latency)")
// or on failure:
Logger.transformation.error("transform_failed: stage=\(stage, privacy: .public) error=\(error)")
```

---

## Common Mistakes

- **Using `print()`** — use `os.Logger` for structured, filterable, privacy-aware logging
- **Logging user text content** — log lengths, not content
- **Logging API keys** — log the Keychain reference, not the key value
- **Using `.fault` for expected errors** — `.fault` is for bugs; use `.error` for expected failures
- **Not specifying `privacy:` on dynamic strings** — defaults to redacted; be explicit about what's public
