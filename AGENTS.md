# AGENTS.md — AI Fine-Tuner

> Universal agent instruction file. Any AI coding agent that reads AGENTS.md will learn to generate interactive HTML fine-tuning GUIs.

## What This Does

Whether building a new component or refining an existing one — in **any programming language** — the agent generates a **single self-contained HTML file** with sliders and an **authentic live preview** of the user's actual element. The preview is always web-based HTML, but the element is translated from the user's stack (Flutter, SwiftUI, React Native, CSS, SVG, JSON, or anything visual) and the output translates back on copy.

Use it during a build to nail visual details (shadows, radii, spacing, colors, timing, SVG attributes, animation curves) the first time, or to replace the "make it bigger… no, smaller… try 12px… actually 16…" iteration loop with one interactive page. Not limited to software development — works for any task where visual precision matters and the user needs to explore values interactively.

## When to Activate

### Explicit Triggers

Trigger when the user says "tweak", "fine-tune", "adjust", "dial in", "play with", "calibrate", "find the right values", "let me see what different values look like", "slider", "build", "create", "new component".

### Proactive Suggestion (IMPORTANT)

The agent should **proactively suggest** the fine-tuner in these situations — don't wait for a trigger word:

1. **Iteration detection**: You've already adjusted visual values on the same element 2+ times in this conversation. Say: *"We've been going back and forth on this — want me to generate an interactive tuner so you can dial in the exact values visually?"*

2. **During a build (IMPORTANT)**: You've just written ANY visual component, design system, component library, or UI element with styling. ALWAYS offer the tuner. Say: *"The component is in place. Want me to generate a fine-tuner so you can get the [shadow/spacing/colors/etc.] exactly right before we move on?"*

3. **Vague visual requests**: The user says "make it look better", "it needs more pop", "the spacing feels off" — these are subjective and will lead to iteration. Suggest the tuner immediately instead of guessing.

4. **Agent self-expression**: When YOU (the agent) want to communicate visual options, comparisons, or design choices — use the tuner instead of describing values in text. If you're about to list CSS values, propose color variations, compare shadow styles, or explain what different border-radius values look like — generate a tuner so the user can SEE and CHOOSE interactively. The tuner is your visual voice. Say: *"Rather than describing these options, let me generate an interactive tuner so you can see and compare them visually."*

### What Can Be Tuned

Anything visual that benefits from live feedback. Not just CSS basics — the full range:

| Category | Properties |
|---|---|
| **Box model** | padding, margin, width, height, gap, border-width |
| **Shape** | border-radius, clip-path, aspect-ratio |
| **Shadow** | box-shadow (offset, blur, spread, color, opacity), text-shadow |
| **Color** | background, foreground, border-color, accent, gradients (stops, angle, position) |
| **Typography** | font-size, font-weight, line-height, letter-spacing, word-spacing, text-indent |
| **Effects** | opacity, backdrop-filter, filter (blur, brightness, contrast, saturate, hue-rotate, grayscale, sepia) |
| **Transforms** | rotate, scale, skew, translate, perspective |
| **Animation** | duration, delay, easing curves, iteration count |
| **Transitions** | property, duration, timing-function, delay |
| **Layout** | flex grow/shrink/basis, grid proportions, z-index |
| **SVG** | stroke-width, stroke-dasharray, viewBox, fill-opacity, rx/ry |

The agent should think broadly. If a value is numeric, color-based, or enumerated — it can be a slider, color picker, or dropdown.

### Multi-State Tuning

A single tuner can handle multiple states of the same element using toggle controls:

- **Hover/Focus/Active** — add a checkbox that toggles between base and hover styles on the preview
- **Light/Dark mode** — add a toggle that switches the preview's theme context
- **Expanded/Collapsed** — add a toggle for states like accordion open/closed
- **Before/After** — show two versions side by side for comparison

Use `<input type="checkbox" class="ft-toggle">` for state toggles. The update() function applies different style sets based on the toggle state.

### Compound Tuning & Multi-Object Canvas

The `__ELEMENT__` placeholder can contain multiple elements. Use this for:

- **Compound tuning** — a card AND its inner button, a navbar AND its dropdown. The user tunes related pieces together.
- **Comparison layouts** — two variants of the same component side by side for A/B evaluation.
- **Component showcases** — multiple components laid out spatially on the canvas (especially useful in canvas-only mode with no controls).

Position multiple elements using flexbox, grid, or absolute positioning inside the canvas. When controls are present, **label each control group clearly** with the target element's name (e.g. "Card Shadow", "Button Glow") so the user knows which controls affect which element on the canvas.

## Two Non-Negotiable Rules

### 1. Preview Authenticity

The preview MUST be a pixel-faithful web reproduction of the user's actual element. Read the real source file. Resolve all abstractions (CSS variables, Tailwind classes, design tokens, theme values) to concrete values. Reproduce the actual markup, text, icons, fonts, and container context. No placeholders. No generic boxes.

For non-web platforms (Flutter, SwiftUI, React Native, Android), create a web-faithful CSS recreation that visually matches the native rendering.

When building a new component: the element was just created — read it from the file you just wrote. The preview reproduces what you built, and the tuner lets the user perfect it.

### 2. Confirm Before Generating

Always ask the user before generating. Present what will be tuned, which files will be read, the output format, and explain: the editor interface is pre-built (infinite canvas, zoom, presets, controls) — you only fill in their element and values. This costs some extra tokens for reading source files and generating HTML, but saves many rounds of back-and-forth iteration. Wait for confirmation. Only exception: user says "just do it" in the same message.

## Template Selection

Choose the template tier based on the number of controls needed. This is critical for saving tokens — the agent fills in ONLY the dynamic parts (element markup, control values, update function). Everything else is built in.

| Controls | Template | Layout |
|----------|----------|--------|
| 1 | `single.html` | Infinite canvas preview, fixed bottom bar with one slider, presets, copy |
| 2–4 | `small.html` | Infinite canvas preview, collapsible bottom panel with slider grid, output, copy |
| 5+ | `full.html` | Collapsible left sidebar with grouped sliders + output + copy, infinite canvas preview |

> **Finding templates:** Search these locations in order (stop at the first match):
> 1. `assets/templates/` relative to this file or the skill directory
> 2. `.fine-tune/templates/` in the project root
> 3. `templates/` relative to this file
> 4. If not found anywhere, generate the template from the placeholder spec below — the full HTML structure with all `__PLACEHOLDER__` tokens is documented in this file

### What You Get for Free (DO NOT rebuild or modify)

Every template includes all of the following — fully built, polished, and ready. The agent MUST NOT add, remove, or rewrite any of this. It comes free with the template:

| Feature | What It Does |
|---|---|
| **Infinite canvas** | Figma-style preview area with trackpad pinch-to-zoom and two-finger pan. Mouse users get Ctrl+scroll zoom. Smooth, no jank. |
| **Zoom HUD** | Bottom-left zoom level display with +/− buttons. Range 25%–400%. |
| **Double-click reset** | Double-click the canvas to snap back to 100% centered. |
| **Editable value readouts** | Every numeric readout (e.g. "12px", "32px") is a clickable input. Users can type an exact value instead of dragging. |
| **Collapsible controls** | Collapse button inside the control panel header. When collapsed, a small tab appears to re-expand. All transitions are GPU-accelerated (`transform` + `will-change`). |
| **Dark/light toggle** | Switch the canvas background between light dot-grid and dark variant. |
| **Preset buttons** | Toolbar of preset buttons calling `setValues({...})`. The infrastructure is built — agent only provides the button markup. |
| **Copy to Clipboard** | One-click clipboard copy with customizable label and success animation. Built in. |
| **Slider track fill** | Range inputs with visual fill tracking (colored portion up to thumb position). |
| **Responsive layout** | Mobile-friendly grid reflow on small screens. |

The agent's ONLY job is to fill in the `__PLACEHOLDER__` values. The template skeleton handles everything else.

### What the Agent Fills In (placeholders)

These are the ONLY dynamic parts — everything the agent needs to inject:

| Placeholder | What to Replace With |
|---|---|
| `__TITLE__` | Short name, e.g. "Card Shadow" — displayed in the panel header |
| `__SUBTITLE__` | Context, e.g. "ProfileCard component" (full template only) — displayed below the title |
| `__GOOGLE_FONTS__` | `<link>` tag for matching fonts, or remove the comment |
| `__ELEMENT__` | The authentic HTML/CSS reproduction of the user's actual element with all styles inlined |
| `__CONTROL_INPUT__` | The `<input>` element (single template only) |
| `__CONTROL_LABEL__` | Label text (single template only) |
| `__DEFAULT_VAL__` | Starting value display (single template only) |
| `__CONTROL_GROUPS__` | Grouped control HTML blocks (small and full templates) |
| `__PRESET_BUTTONS__` | `<button>` elements calling `setValues({...})` — 3-5 presets with "Original" first |
| `__UPDATE_BODY__` | JS body of `update()` function: read control values → apply to preview → update output code |
| `__CTA_LABEL__` | Text for the copy button. Default: `Copy to Clipboard`. Customize for non-tuning contexts (e.g. `Copy CSS`, `Export Config`, `Copy Tokens`). |
| `__BODY_CLASS__` | CSS classes on `<body>`. Default: empty (normal mode). Set `ft-no-panel` to hide the control panel. Set `ft-no-cta` to hide the copy button. Space-separated, e.g. `ft-no-panel ft-no-cta`. |

The agent should NOT modify the template's CSS, layout structure, canvas logic, zoom system, collapse behavior, or utility functions. Use them exactly as-is. This is what makes the system token-efficient — you get a production-quality interactive tool by only writing the parts that are unique to this specific element.

## Control Types

| Value Type | Control | Example |
|---|---|---|
| Length (px, em, rem) | `<input type="range">` | `border-radius: 0-50px` |
| Percentage | `<input type="range">` | `opacity: 0-100%` |
| Angle | `<input type="range">` | `rotation: 0-360deg` |
| Time (ms, s) | `<input type="range">` | `duration: 0-3000ms` |
| Color | `<input type="color">` + optional opacity range | any color prop |
| Enumerated | `<select>` | font-family, easing, blend-mode |
| Boolean | `<input type="checkbox" class="ft-toggle">` | visibility on/off |
| Free text | `<input type="text">` | font-family, custom content, class name, button label |

All range/color/text inputs MUST use `oninput` (not `onchange`) for instant feedback.

### Proactive Text Fields

The agent should **proactively add text input fields** when they would improve the preview or give the user more control — even if the user didn't explicitly ask. Examples:
- Tuning a button? Add a text field for the button label so the user can see how different text lengths affect the design.
- Tuning a card? Add a text field for the title/subtitle to test with realistic content.
- Tuning typography? Add a text field for sample text.

Text fields update the preview in real-time (via `oninput`) but are NOT included in the "Copy to Clipboard" output — they're preview helpers, not style values. The update() function should use them to change `el.textContent` or `el.innerHTML` on the preview element, not to generate framework output.

## Control HTML Patterns

For small and full templates, each control follows this structure:

```html
<div class="ft-control">
  <div class="ft-control-label">
    <span>Border Radius</span>
    <span class="ft-val" id="v-radius">12px</span>
  </div>
  <div class="ft-control-row">
    <input type="range" id="radius" min="0" max="50" step="1" value="12"
           oninput="update()" aria-label="Border radius">
  </div>
</div>
```

For color + opacity:

```html
<div class="ft-control">
  <div class="ft-control-label">
    <span>Shadow Color</span>
    <span class="ft-val" id="v-shadow-color">#000000 40%</span>
  </div>
  <div class="ft-control-row">
    <input type="color" id="shadow-color" value="#000000" oninput="update()" aria-label="Shadow color">
    <input type="range" id="shadow-opacity" min="0" max="100" step="1" value="40"
           oninput="update()" aria-label="Shadow opacity">
  </div>
</div>
```

For text input:

```html
<div class="ft-control">
  <div class="ft-control-label">
    <span>Font Family</span>
    <span class="ft-val" id="v-font">Inter</span>
  </div>
  <div class="ft-control-row">
    <input type="text" id="font" value="Inter" placeholder="e.g. Inter, Roboto"
           oninput="update()" aria-label="Font family">
  </div>
</div>
```

## Group HTML Pattern (full template only)

```html
<div class="ft-group">
  <div class="ft-group-title">
    <span class="dot" style="background:#3b82f6"></span> Shadow
  </div>
  <!-- controls here -->
</div>
```

## Output Formats

Detect from the user's stack and output accordingly:

| Stack | Format |
|---|---|
| CSS (default) | `border-radius: 12px; box-shadow: ...;` |
| Tailwind | `rounded-xl shadow-lg bg-[#1a1a2e]` |
| Flutter | `BorderRadius.circular(12), BoxShadow(...)` |
| SwiftUI | `.cornerRadius(12) .shadow(...)` |
| React Native | `borderRadius: 12, shadowOffset: {...}` |
| JSON | `{ "borderRadius": 12, ... }` |

The clipboard output should be wrapped with a header that enables cross-session reuse:

```
/* Fine-Tuned: [element]-[property] | [source file relative path] */

[framework code]
```

## Presets

Include 3-5 presets. "Original" (actual codebase values) is always first.

| Name | Philosophy |
|---|---|
| Original | Current values from codebase (always first) |
| Subtle | Restrained, barely-there |
| Elevated | Clear lift, professional |
| Bold | Dramatic, attention-grabbing |
| Soft | Diffused, organic |
| Sharp | Hard edges, precise |
| Neon | Colored shadow/border, futuristic |
| Glass | Frosted, translucent |

Presets are implemented as toolbar buttons calling `setValues({id: value, ...})`.

## Cross-Platform Rendering

| Platform | Web Equivalent |
|---|---|
| Flutter `EdgeInsets(16)` | `padding: 16px` |
| Flutter `BorderRadius.circular(12)` | `border-radius: 12px` |
| Flutter `BoxShadow` | `box-shadow` |
| Flutter `Colors.blue` | `#2196F3` |
| Flutter `elevation: 4` | Material shadow formula in `box-shadow` |
| SwiftUI `.cornerRadius(12)` | `border-radius: 12px` |
| SwiftUI `.shadow(radius:8)` | `box-shadow: 0 0 8px ...` |
| SwiftUI `.padding(16)` | `padding: 16px` |
| React Native `borderRadius: 12` | `border-radius: 12px` (unitless = px) |
| Android `16dp` | `16px` |

## Persistent Fine-Tuner Storage

All fine-tuners are stored in a `.fine-tune/` folder at the project root. Each tuner gets its own subfolder containing the HTML (user-facing) and a context file (agent-facing).

```
.fine-tune/
├── card-shadow/
│   ├── fine-tune-card-shadow.html   ← user opens this in browser
│   └── context.md                   ← agent reads this for reuse
├── button-hover/
│   ├── fine-tune-button-hover.html
│   └── context.md
```

### Folder & File Naming

```
.fine-tune/[element]-[property]/
├── fine-tune-[element]-[property].html
└── context.md
```

Examples: `.fine-tune/card-shadow/`, `.fine-tune/nav-spacing/`, `.fine-tune/button-hover/`

### context.md Format

The context file is brief — just enough for any agent session to understand what was tuned and where to apply pasted values. Do NOT dump full styles or HTML here.

```markdown
# Fine-Tuner: [Title]

- **Element**: [component/widget name]
- **Source**: [relative path to source file]
- **Framework**: [CSS / Tailwind / Flutter / SwiftUI / React Native]
- **Parameters**: [comma-separated list of what's tunable]
- **Created**: [date]
- **Last regenerated**: [date]
```

### Reuse Flow

Before creating a new fine-tuner, check if `.fine-tune/` already has a matching one:

1. Scan `.fine-tune/*/context.md` for a match (same element + overlapping parameters)
2. **If match found**: read the context.md, verify the source file still exists and the element is still there, then **regenerate** the HTML from the current source (the old HTML is stale — the element may have changed). Update `Last regenerated` in context.md.
3. **If no match**: create a new subfolder with both files.

This means the HTML always reflects the latest code, while context.md provides continuity across sessions.

### Cross-Session Paste Flow

The "Copy to Clipboard" output includes a header comment:

```
/* Fine-Tuned: [element]-[property] | [source file path] */
```

When a user pastes this into a new agent session, the agent should:
1. Parse the header to identify the element and source file
2. Check `.fine-tune/*/context.md` for additional context if available
3. Apply the values to the source file directly

### .gitignore

Add `.fine-tune/` to `.gitignore` — these are local tuning artifacts, not source code.

## Theme Matching

If the project has a design system, theme config, or consistent color palette (e.g. Tailwind config, CSS custom properties, Material theme, design tokens), adapt the tuner UI to match:
- Override the template's CSS variables (`--ft-bg`, `--ft-surface`, `--ft-accent`, `--ft-text`, etc.) to use the project's colors
- Use the project's font stack
- This makes the tuner feel native and helps the user judge visual changes in context

If no design system exists, use the template defaults.

## Generation Workflow

```
1.  User triggers fine-tune request
2.  Agent checks .fine-tune/*/context.md for an existing tuner that matches
3.  Agent presents confirmation (what, files, tokens, reuse if found)
4.  User confirms
5.  Agent reads source file(s)
6.  Agent extracts: markup, styles, fonts, tokens→values, context, framework
7.  Agent selects template tier (1 control → single, 2-4 → small, 5+ → full)
8.  Agent fills in template placeholders (element, controls, update(), presets, output)
9.  Agent writes HTML + context.md to .fine-tune/[name]/ (create or overwrite)
10. Agent opens the HTML in the default browser
11. Agent tells the user what to do — always include the full file path:

    "Opened fine-tune-[name].html in your browser.
     Full path: [absolute path]

     Drag the sliders to find your perfect values, then click
     'Copy to Clipboard' and paste the result back here —
     I'll apply them to your code."

12. User tunes → clicks "Copy to Clipboard" → pastes back
13. Agent applies ALL values EXACTLY as copied — no judgment calls, no "keeping design tokens", no partial application. The user tuned these values intentionally. Apply every single property from the pasted output without modification.
```

## Constraints

- Self-contained: No external JS. Only external resource: Google Fonts CDN.
- No build step: Must work via `file://` protocol.
- Performant: Updates < 16ms. Use `oninput` + direct `el.style` manipulation.
- Accessible: Native `<input>` elements with `aria-label` attributes.
- Template-first: Never generate template chrome from scratch. Read the template file, fill in placeholders. The canvas, zoom, collapse, copy, presets, layout — all built in.

## Beyond Fine-Tuning (Advanced)

The same templates power more than parameter tuning. The control panel and CTA button are both optional — set `__BODY_CLASS__` to `ft-no-panel` (canvas only), `ft-no-cta` (controls without copy), or both. The `__CTA_LABEL__` placeholder lets you customize the button text for non-tuning use cases (e.g. "Export SVG", "Copy HTML").

Use these modes when the user needs to **see** something interactive rather than **tune** values — layout previews, component showcases, data visualizations, or multi-object comparisons. The infinite canvas with zoom/pan works the same regardless of mode.

**Default to fine-tuning mode unless the task clearly isn't about dialing in values.** The fine-tuning workflow above is the primary use case.

## Agent-Specific Notes

### Claude Code / Claude Plugins
See `skills/ai-fine-tuner/SKILL.md` for Claude-specific skill format with YAML frontmatter.

### Cursor
Add to `.cursor/rules` or `.cursorrules`:
```
When the user asks to fine-tune or tweak visual parameters on an existing element,
follow the spec in AGENTS.md to generate an interactive HTML tuning interface.
Always confirm before generating. The preview must reproduce the ACTUAL element.
```

### OpenAI Codex
Add to `codex.md` or `AGENTS.md` in your repo root. Codex reads AGENTS.md by convention and will follow these instructions automatically.

### Windsurf / Cline / Continue / Aider / Copilot / bolt.new / Lovable / Replit Agent
Place this `AGENTS.md` in your project root. Most agents read it automatically. For agents with limited instruction space, use the minimum viable instruction:

```
FINE-TUNE PLUGIN:
0. Check .fine-tune/*/context.md for existing tuner match
1. Confirm with user first (what, files, tokens)
2. Read source file of element being tuned
3. Extract ALL styles (resolve variables/tokens/classes to concrete values)
4. Pick template: 1 control → single.html, 2-4 → small.html, 5+ → full.html
5. Fill in placeholders only — do NOT rewrite template CSS/layout
6. All controls use oninput for instant updates
7. Add text fields proactively for preview content (labels, titles, sample text)
8. Write HTML + context.md to .fine-tune/[name]/
9. Open in browser, print full path, instruct user to copy decisions and paste back
```

### When Agent Can't Read Files
1. Ask user to paste element code + styles
2. Ask for: font, colors, dimensions, background context
3. Generate from pasted info
4. Caveat: "Preview may not be 100% faithful"
