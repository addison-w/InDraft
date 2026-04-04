# Backend Development Guidelines (Services / Data Layer)

> Best practices for services, SwiftData models, Keychain, networking, and system integrations in InDraft.

---

## Overview

This directory contains guidelines for InDraft's service/data layer. InDraft has no server — "backend" means the local service layer: SwiftData persistence, Keychain for secrets, Accessibility API, AI provider networking, global hotkey registration, and clipboard management.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Services, Models, Utilities organization | Filled |
| [Database Guidelines](./database-guidelines.md) | SwiftData models, relationships, queries | Filled |
| [Error Handling](./error-handling.md) | Domain error enums, fallback chains, user messaging | Filled |
| [Quality Guidelines](./quality-guidelines.md) | DI, security, concurrency, testing | Filled |
| [Logging Guidelines](./logging-guidelines.md) | os.Logger, privacy, structured logging | Filled |

---

## Pre-Development Checklist

Before writing any service/data code, read the files relevant to your task:

- **Creating a new service?** → directory-structure.md + quality-guidelines.md
- **Working with SwiftData?** → database-guidelines.md
- **Handling errors or fallbacks?** → error-handling.md
- **Adding logging?** → logging-guidelines.md
- **Touching Keychain or secrets?** → quality-guidelines.md (Security Rules)

---

**Language**: All documentation should be written in **English**.
