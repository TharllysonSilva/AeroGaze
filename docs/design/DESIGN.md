# Design System Strategy: The Command Horizon

## 1. Overview & Creative North Star: "The Tactical Observer"
This design system moves away from the friendly, rounded "SaaS" look of the 2020s and embraces **The Tactical Observer**—a high-fidelity, command-center aesthetic that feels engineered rather than merely "designed." 

The North Star is **Functional Brutalism**. We break the "template" look by using intentional asymmetry, where data-heavy sidebars contrast against wide, cinematic workspaces. We treat the UI as a glass cockpit: high-contrast typography, technical precision, and a layered depth that suggests sophisticated AI processing happening beneath the surface. This is not just a dashboard; it is a mission-critical instrument.

---

## 2. Colors: Tonal Depth & The "No-Line" Rule
The palette is rooted in a "Charcoal" foundation with "Bio-Green" accents, creating a visual link between high-tech optics and biological surveillance.

### The Foundation
*   **Background:** `#121414` (The void of the command center).
*   **Primary (Bio-Green):** `#a3f69b` (Primary) to `#88d982` (Container). Used for active states and critical data.
*   **Secondary (Electric Blue):** `#00e3fd` (Container) to `#bdf4ff` (Secondary). Reserved strictly for telemetry and data-stream visualization.

### The "No-Line" Rule
Standard 1px borders are strictly prohibited for sectioning. To separate content, use **Tonal Transitions**:
*   A `surface-container-low` section sitting on a `surface` background.
*   The boundary is defined by the shift in the charcoal depth, not a stroke. This creates a more immersive, seamless "industrial" feel.

### The Glass & Gradient Rule
Floating elements (modals, popovers) must utilize **Glassmorphism**: 
*   **Fill:** `surface-container` at 70% opacity.
*   **Backdrop Blur:** 12px to 20px.
*   **CTA Soul:** Use a subtle linear gradient from `primary` (#a3f69b) to `primary-container` (#88d982) at a 135-degree angle to give buttons a "lit from within" glow.

---

## 3. Typography: Technical Authority
We pair the geometric aggression of **Space Grotesk** with the neutral clarity of **Inter**.

*   **Display & Headlines (Space Grotesk):** These are your "readouts." Use `display-lg` (3.5rem) for hero data points. Space Grotesk’s technical quirks provide the "Command Center" soul.
*   **Body & Titles (Inter):** High-legibility sans-serif. Use `body-md` (0.875rem) for the majority of the interface to maintain a compact, data-dense look.
*   **Labels (Space Grotesk):** `label-sm` (0.6875rem) should be used for all micro-copy and metadata, often in All-Caps with +5% letter spacing to mimic aeronautical labeling.

---

## 4. Elevation & Depth: Tonal Layering
In a dark, industrial theme, shadows often look muddy. We replace traditional shadows with **Tonal Layering** and **Ambient Light**.

*   **The Layering Principle:** 
    *   `surface-container-lowest`: Deep background tasks.
    *   `surface-container-low`: The main workspace.
    *   `surface-container-high`: Interactive cards/panels.
*   **The "Ghost Border" Fallback:** If high-density data requires a container boundary, use the `outline-variant` (#40493d) at 15% opacity. This creates a "etched" look rather than a drawn line.
*   **Ambient Glow:** For high-priority elements, use a shadow with a blur of 30px, 0% offset, and 5% opacity using the `primary` color (#88d982) instead of black.

---

## 5. Components: Engineered Primitives

### Cards (The "Glass Panel")
*   **Radius:** Always `md` (12px / 0.75rem).
*   **Background:** `surface-container-low` at 80% opacity with 16px backdrop-blur.
*   **Dividers:** **Forbidden.** Use vertical spacing (1.5rem+) or a shift to `surface-container-high` for internal sections.

### Buttons (The "Actuator")
*   **Primary:** Solid `primary-container` (#88d982). Text in `on-primary-fixed` (#002203).
*   **Secondary/Telemetry:** Ghost style. No background, `secondary` (#bdf4ff) text, and a `Ghost Border` (15% opacity secondary).
*   **States:** On hover, increase the background opacity or add a 2px outer glow of the same color.

### Inputs (The "Data Entry")
*   **Style:** Flat `surface-container-lowest` with a bottom-only 2px "indicator" bar that glows `primary` when focused.
*   **Typography:** All input labels must be `label-md` in Space Grotesk.

### Telemetry Chips
*   Small, rectangular chips with `none` or `sm` (4px) radius. 
*   Used for status: `Online` (Bio-Green), `Calibrating` (Electric Blue), `Error` (Error #ffb4ab).

---

## 6. Do's and Don'ts

### Do:
*   **Embrace Density:** Industrial interfaces are efficient. Don't be afraid of high-information density as long as the hierarchy is clear.
*   **Use Monospaced Figures:** Ensure all numerical data uses tabular lining (monospaced numbers) to prevent "jumping" during real-time updates.
*   **Asymmetric Layouts:** Use a 12-column grid but break it. Place a narrow 2-column "System Status" rail against a wide 10-column "Visual Feed."

### Don't:
*   **Don't use 100% white:** Use `on-surface` (#e2e2e2) to prevent eye strain in the dark theme.
*   **Don't use standard shadows:** They feel "organic" and "soft." This system is "hard" and "engineered." Use tonal shifts instead.
*   **Don't use rounded pills:** Keep the 12px (`md`) radius consistent. Circles and pills feel too consumer-focused for a command center.

### Director's Final Note:
*Every pixel should look like it was placed there for a tactical reason. If a design element doesn't serve to clarify data or indicate an action, strip it away. This is the beauty of Industrial Minimalism.*