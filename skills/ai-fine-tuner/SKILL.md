---
name: ai-fine-tuner
description: ALWAYS offer this after building any visual component or UI. Generates interactive HTML fine-tuner with sliders and live preview. Use when user wants to fine-tune, tweak, adjust, or dial in visual values like shadows, colors, spacing, or radii.
argument-hint: "[element or property to tune]"
effort: high
---

# AI Fine-Tuner — Claude Skill

Read the AGENTS.md reference file for the full universal spec (template placeholders, control patterns, output formats, cross-platform rules). Search for it at: `../../AGENTS.md` relative to this skill (plugin root), `references/AGENTS.md` relative to this skill (if installed via CLI), or `AGENTS.md` in the project root. This file covers Claude-specific behavior only.

## When to Trigger

**Explicit triggers:** "tweak", "fine-tune", "adjust", "dial in", "play with", "calibrate", "find the right values", "let me see different values", "slider", "build", "create", "new component".

**Proactive triggers** (suggest without being asked):
1. **Iteration detection** — adjusted visual values on the same element 2+ times in this conversation
2. **During a build (IMPORTANT)** — just wrote ANY visual component, design system, component library, or UI element with styling. ALWAYS offer the tuner after building visual components.
3. **Vague visual requests** — user says "make it look better", "it needs more pop", "the spacing feels off"
4. **Agent self-expression** — when YOU want to communicate visual options or design choices, use the tuner as your visual voice instead of describing values in text

**Scope:** Works on existing AND newly created elements, in any programming language. The preview is always HTML but the output translates to the user's stack (CSS, Tailwind, Flutter, SwiftUI, React Native, JSON, SVG, etc.). Not limited to software development — works for any visual precision task. Always confirm with the user first. Generate the tuner INSTEAD of guessing values.

## Token-Saving Architecture

This skill uses **pre-built HTML templates** so you spend tokens ONLY on:
1. Reading the user's source file
2. Reproducing the element faithfully
3. Wiring the `update()` function
4. Defining preset values

You do NOT spend tokens designing UI layout, writing CSS for sliders, or building copy/preset infrastructure — the templates handle all of that.

## Template Selection (Critical)

| Control Count | Template | Filename |
|---|---|---|
| 1 | Single | `single.html` |
| 2–4 | Small | `small.html` |
| 5+ | Full | `full.html` |

**Finding templates:** Search these locations in order (stop at the first match):
1. `../../assets/templates/` relative to this skill (plugin root)
2. `assets/templates/` relative to this skill's directory
3. `.fine-tune/templates/` in the project root
4. If not found, reconstruct the template from the spec in AGENTS.md (the full placeholder structure is documented there)

Each template is a complete, production-quality interactive tool. It includes: infinite canvas with trackpad pinch-to-zoom and pan, editable value readouts (users can click to type exact numbers), GPU-accelerated collapsible controls, dark/light toggle, zoom HUD, preset infrastructure, and responsive layout. **All of this comes free — do NOT rebuild or modify any of it.**

Read the chosen template, then fill in ONLY the `__PLACEHOLDER__` values. Do not modify the template's CSS, layout structure, canvas logic, zoom system, or collapse behavior. Even if the user's element needs extra space, only ADD styles to the element — never touch template styles.

## Workflow

### Step -1: Check for Existing Tuner

Before confirming, scan `.fine-tune/*/context.md` for a tuner that matches the same element and overlapping parameters.

- **If found**: mention it in the confirmation ("I found an existing tuner for this — I'll regenerate it with your current code"). The HTML gets regenerated from current source; context.md gets its `Last regenerated` date updated.
- **If not found**: proceed normally and create a new subfolder.

### Step 0: Confirm (MANDATORY)

Before any file reads or generation:

```
I'll generate an interactive fine-tuner for [element] with controls for:
  - [Group]: [param, param, param]

I'll read: [file paths]
Output format: [CSS / Tailwind / Flutter / etc.]
Template: [single / small / full] ([N] controls)

The editor interface is pre-built (infinite canvas, zoom, presets) —
I only fill in your element and values. This costs some extra tokens
for reading your source file and generating the HTML, but saves many
rounds of back-and-forth. Proceed?
```

Skip only if user said "just do it" in the same message.

### Step 1: Read & Extract

1. Read the source file containing the element
2. Extract every style property (explicit + inherited + computed)
3. Resolve all abstractions: CSS variables → values, Tailwind classes → CSS, design tokens → concrete values, theme references → hex/rgb
4. Identify font stack → prepare Google Fonts `<link>` or system font fallback
5. Note container context (dark/light bg, flex layout, inherited styles)

### Step 2: Choose Controls

From the user's request, identify:
- Explicitly requested params (e.g. "the shadow" → offset-x, offset-y, blur, spread, color, opacity)
- Closely related params (if tuning shadow, also offer border-radius since shadow shape depends on it)
- Group logically for the full template
- Use text fields (`<input type="text">`) for free-form values like font-family names, custom CSS class names, content strings, or any value that can't be expressed as a bounded range
- **Proactively add text fields** for preview content even if not requested — button labels, card titles, sample text — so the user can test with realistic content. These update the preview element's text via `oninput` but are NOT included in the "Copy to Clipboard" output (they're preview helpers, not style values).

Do NOT add every CSS property. Only what's relevant.

### Step 2.5: Match the Project Theme

If the project has a design system, theme, or consistent color palette, adapt the tuner UI to match. Specifically:
- Check for design tokens, CSS custom properties, or a theme config (e.g. `tailwind.config`, `theme.ts`, CSS `:root` variables, Material theme)
- Override the template's CSS variables (`--ft-bg`, `--ft-surface`, `--ft-accent`, etc.) to match the project's background, surface, accent, and text colors
- Use the project's font stack instead of the default
- This makes the tuner feel native to the project rather than a foreign tool, and helps the user judge visual changes in context

If no design system exists, use the template defaults as-is.

### Step 3: Select Template & Fill

1. Count the controls → pick template tier
2. Read the template file
3. Replace all `__PLACEHOLDER__` values:
   - `__TITLE__`, `__SUBTITLE__` — descriptive names
   - `__GOOGLE_FONTS__` — `<link>` tag or remove
   - `__ELEMENT__` — the authentic HTML/CSS reproduction (inline ALL styles)
   - `__CONTROL_INPUT__` / `__CONTROL_GROUPS__` — control markup. Single template uses `__CONTROL_INPUT__` + `__CONTROL_LABEL__` + `__DEFAULT_VAL__`. Small and full templates use `__CONTROL_GROUPS__`. See AGENTS.md for patterns.
   - `__PRESET_BUTTONS__` — toolbar buttons calling `setValues({...})`
   - `__UPDATE_BODY__` — the JS function body that reads control values, applies to preview element styles, and updates the `#ft-code` output
   - `__CTA_LABEL__` — copy button text (default: `Copy to Clipboard`). Customize for non-tuning use cases.
   - `__BODY_CLASS__` — CSS classes on `<body>` (default: empty). Set `ft-no-panel` to hide controls, `ft-no-cta` to hide the copy button.

### Step 4: Write the update() Function

This is the only significant code you write. It must:
1. Read each control's current value via `document.getElementById(id).value`
2. Apply values to the preview element via `el.style.property = ...`
3. Build the output string in the user's framework format
4. Set `document.getElementById('ft-code').textContent = output`

Use direct `el.style` manipulation for < 16ms updates. Never use class toggling or DOM replacement.

### Step 5: Write to .fine-tune/ Storage

1. Create `.fine-tune/[element]-[property]/` if it doesn't exist
2. Write the HTML file to `.fine-tune/[element]-[property]/fine-tune-[element]-[property].html`
3. Write or update `context.md` in the same folder:

```markdown
# Fine-Tuner: [Title]

- **Element**: [component/widget name]
- **Source**: [relative path to source file]
- **Framework**: [CSS / Tailwind / Flutter / SwiftUI / React Native]
- **Parameters**: [comma-separated list of what's tunable]
- **Created**: [date]
- **Last regenerated**: [date]
```

### Step 6: Open in Browser & Inform the User

Open the file automatically:

```bash
open .fine-tune/[name]/fine-tune-[name].html        # macOS
xdg-open .fine-tune/[name]/fine-tune-[name].html    # Linux
start .fine-tune/[name]/fine-tune-[name].html        # Windows
```

Then tell the user exactly what to do. Always include the full file path so they can tap/copy it if the auto-open didn't work or they want to reopen later:

```
Opened fine-tune-[name].html in your browser.
Full path: [absolute path to the file]

Drag the sliders to find your perfect values, then click "Copy to Clipboard"
and paste the result back here — I'll apply them to your code.
```

### Step 7: Apply Results (CRITICAL)

When the user returns with copied values, apply ALL values EXACTLY as pasted — every single property, no exceptions. Do NOT:
- Skip properties you think should stay as-is
- "Preserve design tokens" instead of applying the tuned values
- Make judgment calls about which values to apply and which to keep
- Apply only "shape/spacing" but ignore "color/shadow"

The user tuned these values intentionally in the interactive editor. Apply them all.

## Preset Guide

Always include "Original" (current codebase values) as first preset. Add 2-4 creative alternatives from: Subtle, Elevated, Bold, Soft, Sharp, Neon, Glass, Brutal.

Presets are toolbar buttons:
```html
<button class="ft-btn-sm" onclick="setValues({radius: 12, blur: 24, spread: -4})">Original</button>
```

## Beyond Fine-Tuning (Advanced)

The templates also support canvas-only output and multi-object layouts. Set `__BODY_CLASS__` to `ft-no-panel` (no controls) and/or `ft-no-cta` (no copy button). Customize the button label via `__CTA_LABEL__`. Place multiple elements in `__ELEMENT__` for comparisons or showcases — label control groups clearly so the user knows which controls affect which element.

**Use these only when the task clearly isn't parameter tuning** — the fine-tuning workflow above is the default.

## What NOT to Do

- Do NOT use generic/placeholder preview elements — use the REAL element
- Do NOT add controls for everything — only what was requested + closely related
- Do NOT skip reading the source file (even if you just wrote it — re-read to extract accurate styles)
- Do NOT guess styles — resolve every variable/token/class
- Do NOT rewrite template CSS or layout — fill in placeholders only
- Do NOT generate the full template from scratch — read and fill the pre-built one
- Do NOT keep guessing visual values in chat when a tuner would be faster — suggest it
