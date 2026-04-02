# Design System Specification: High-End Utilitarian Editorial

## 1. Overview & Creative North Star
**Creative North Star: "The Technical Curator"**

This design system moves beyond basic minimalism into the realm of high-end digital editorialism. It is designed for a macOS environment where precision meets warmth. Rather than relying on the cold, sterile grids of standard utility apps, this system utilizes **intentional asymmetry, breathability, and tonal depth** to create an interface that feels like a bespoke workstation.

The "Technical Curator" aesthetic is defined by three pillars:
1.  **Spaciousness as Luxury:** White space is not "empty"; it is a functional tool used to reduce cognitive load.
2.  **Architectural Layering:** Hierarchy is communicated through the stacking of surfaces rather than the drawing of lines.
3.  **Typographic Authority:** Clear distinctions between functional UI text and "Information Headlines" create an editorial flow that guides the eye.

---

## 2. Colors & Surface Logic

The palette is grounded in "Warm Bone" and "Charcoal," providing a high-contrast yet soft reading experience.

### Surface Hierarchy & The "No-Line" Rule
To achieve a premium feel, **1px solid borders are prohibited for sectioning.** Boundaries must be defined through background shifts or "Ghost Borders."

*   **The Layering Principle:** Use the `surface-container` tiers to create depth. A `surface-container-lowest` card should sit atop a `surface-container-low` section. This creates a soft, natural lift.
*   **Signature Tonal Transitions:** Use `surface-bright` (#faf9f6) for the most active workspace areas and `surface-dim` (#d6dbd5) for peripheral utility panels.
*   **The Accent Rule:** The "Pale Blue" (`secondary-container` #d3e5f0) is reserved strictly for active states, selection pills, and focused interactive elements. It should never be used for large backgrounds.

| Role | Token | Hex | Usage |
| :--- | :--- | :--- | :--- |
| **Background** | `surface` | `#faf9f6` | The base "Warm Bone" canvas. |
| **Primary Text** | `on-surface` | `#2f3430` | High-readability Charcoal. |
| **Secondary Text** | `on-surface-variant`| `#5c605c` | For metadata and labels. |
| **Accent (Active)** | `secondary-container`| `#d3e5f0` | Selection states and pills. |
| **Subtle UI** | `outline-variant` | `#afb3ae` | Only for "Ghost Borders" at 10-20% opacity. |

### Full Color Token Reference

| Token | Hex |
| :--- | :--- |
| `background` | `#faf9f6` |
| `surface` | `#faf9f6` |
| `surface-bright` | `#faf9f6` |
| `surface-container` | `#edeeea` |
| `surface-container-high` | `#e6e9e4` |
| `surface-container-highest` | `#e0e4de` |
| `surface-container-low` | `#f4f4f0` |
| `surface-container-lowest` | `#ffffff` |
| `surface-dim` | `#d6dbd5` |
| `surface-tint` | `#5a5f62` |
| `surface-variant` | `#e0e4de` |
| `on-background` | `#2f3430` |
| `on-surface` | `#2f3430` |
| `on-surface-variant` | `#5c605c` |
| `primary` | `#5a5f62` |
| `primary-container` | `#dfe3e7` |
| `primary-dim` | `#4e5356` |
| `on-primary` | `#f4f8fc` |
| `on-primary-container` | `#4d5256` |
| `secondary` | `#51616b` |
| `secondary-container` | `#d3e5f0` |
| `secondary-dim` | `#45555e` |
| `on-secondary` | `#f3faff` |
| `on-secondary-container` | `#43545d` |
| `tertiary` | `#5e5f5f` |
| `tertiary-container` | `#f4f3f3` |
| `tertiary-dim` | `#525354` |
| `on-tertiary` | `#f9f9f9` |
| `on-tertiary-container` | `#5a5c5c` |
| `outline` | `#777c77` |
| `outline-variant` | `#afb3ae` |
| `error` | `#9f403d` |
| `error-container` | `#fe8983` |
| `on-error` | `#fff7f6` |
| `on-error-container` | `#752121` |
| `inverse-surface` | `#0d0f0d` |
| `inverse-on-surface` | `#9d9d9a` |
| `inverse-primary` | `#f6fafe` |

---

## 3. Typography

The typography system pairs **Manrope** (Display/Headlines) for a modern, architectural feel with **Inter** (Body/Labels) for maximum legibility.

*   **Display & Headlines (Manrope):** Use these for titles and large editorial moments. The slightly wider tracking in Manrope conveys a sense of technical precision.
*   **Body & Labels (Inter):** Reserved for functional UI, input fields, and long-form reading.
*   **Kbd (Monospace):** Use a system mono (e.g., SF Mono) for keyboard shortcuts. This reinforces the "utilitarian" nature of the tool.

**Key Scales:**
*   **Display-MD:** 2.75rem (Manrope) — Use for empty state headers or primary navigation titles.
*   **Title-SM:** 1rem (Inter) — The standard for sidebar items and section headers.
*   **Label-SM:** 0.6875rem (Inter) — For keyboard shortcuts and micro-metadata.

---

## 4. Elevation & Depth

We reject traditional drop shadows in favor of **Tonal Layering** and **Ambient Diffusion.**

*   **Tonal Stacking:** Instead of a shadow, place a `surface-container-highest` (#e0e4de) element behind a `surface-container-lowest` (#ffffff) element to create separation.
*   **Ambient Shadows:** If a floating element (like a popover) requires a shadow, use a large blur (24px+) with an extremely low opacity (4%). The shadow color must be derived from `on-surface` (Charcoal), never pure black.
*   **Glassmorphism:** For macOS-native feel, floating panels should use `surface` at 80% opacity with a `backdrop-blur` of 20px. This allows the "Warm Bone" background to bleed through, softening the interface.
*   **The Ghost Border:** If a container sits on a background of the same color, use `outline-variant` at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons & Pills
*   **Primary:** `primary` (#5a5f62) background with `on-primary` (#f4f8fc) text. 8px radius.
*   **Secondary (Pill):** `secondary-container` (#d3e5f0) background with `on-secondary-fixed` (#31424a) text. Fully rounded (`full`).
*   **Tertiary:** No background. `on-surface` text. Uses a subtle `surface-container-high` background shift on hover.

### Input Fields
*   **Structure:** No bottom line or heavy border. Use `surface-container-low` as a subtle trough.
*   **Focus State:** A 1px "Ghost Border" using `primary` at 40% opacity. No "glow" effects.

### Cards & Lists
*   **Forbidden:** Divider lines between list items.
*   **Alternative:** Use `spacing-4` (1.4rem) of vertical white space to separate items. In dense lists, use alternating background shift of `surface-container-lowest` and `surface`.

### Additional Component: The "Shortcut Breadcrumb"
Given the macOS context, use a `tertiary-container` (#f4f3f3) small pill containing Monospace text to indicate navigation shortcuts next to section titles.

---

## 6. Spacing

Spacing scale factor: **3**

| Scale | Value |
| :--- | :--- |
| `spacing-1` | 0.25rem |
| `spacing-2` | 0.5rem |
| `spacing-3` | 0.75rem |
| `spacing-4` | 1.4rem |
| `spacing-6` | 2rem |
| `spacing-8` | 2.75rem |
| `spacing-12` | 4rem |
| `spacing-16` | 5.5rem |

---

## 7. Roundness

Standard border radius: **8px (0.5rem)**

Use `8px` as the standard radius for all containers to maintain a soft but technical silhouette.

---

## 8. Do's and Don'ts

### Do
*   **Do** use asymmetrical margins (e.g., a wider left margin than right) to create an editorial, magazine-like layout.
*   **Do** lean on `spacing-12` (4rem) and `spacing-16` (5.5rem) to separate major functional blocks.
*   **Do** use `8px (0.5rem)` as the standard radius for all containers.

### Don't
*   **Don't** use emojis. Use refined, lightweight SVG icons (2px stroke) if visual cues are necessary.
*   **Don't** use pure black (#000) or pure white (#FFF) unless it is for the `surface-container-lowest` token.
*   **Don't** use 100% opaque borders. They clutter the "Warm Bone" aesthetic and break the editorial flow.
*   **Don't** use gradients. Depth is achieved through layering flat tones, not color ramps.
