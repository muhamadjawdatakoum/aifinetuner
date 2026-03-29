# AI Fine-Tuner — OpenAI Codex Implementation

> Read `../AGENTS.md` for the full universal specification.

## When to Trigger

Proactively suggest the fine-tuner when: (1) you've adjusted visual values 2+ times, (2) you just built a new component with visual styling, (3) the user gives vague visual feedback, or (4) you want to communicate visual options — use the tuner as your visual voice instead of listing values in text.

## Codex-Specific Setup

Codex reads `AGENTS.md` from the repository root by convention. Place the project's `AGENTS.md` there, or reference it from your Codex configuration.

### As a codex.md Instruction

Add to `codex.md` or your Codex system prompt:

```
When the user asks to fine-tune, tweak, adjust, or dial-in visual parameters
on an existing element, follow the spec in AGENTS.md to generate an
interactive HTML tuning interface instead of iterating on values in code.

Always confirm with the user before generating. Summarize what will be tuned,
which files will be read, and warn about extra token usage. Wait for
confirmation before proceeding.

Critical: The preview must faithfully reproduce the ACTUAL element from
the codebase, not a generic placeholder.

Use the pre-built template (single.html, small.html, or full.html based on
control count) and fill in only the placeholders. Do not rewrite template CSS.
```

### Workflow in Codex

1. User asks to fine-tune a visual property on an existing element
2. Agent presents confirmation summary (what, files, tokens, template tier)
3. User confirms
4. Agent reads the source file using its file access capabilities
5. Agent selects template: 1 control → `single.html`, 2-4 → `small.html`, 5+ → `full.html`
6. Agent fills in template placeholders (element, controls, update function, presets)
7. Agent writes file to project directory
8. User opens the HTML file, tunes values, clicks "Copy to Clipboard"
9. User pastes values back or asks agent to apply

### Template Selection

Codex should count the number of controls needed and select the appropriate tier:

| Controls | Template | Why |
|----------|----------|-----|
| 1 | `assets/templates/single.html` | Minimal: bottom bar with one slider |
| 2–4 | `assets/templates/small.html` | Compact: bottom panel with slider grid |
| 5+ | `assets/templates/full.html` | Full: left sidebar with grouped sliders |

This saves tokens — Codex fills in placeholders instead of designing UI from scratch.

### Output Location

Save generated tuners to:
```
.fine-tune/[element]-[property]/fine-tune-[element]-[property].html
.fine-tune/[element]-[property]/context.md
```

The `context.md` file stores element metadata for cross-session reuse. Add `.fine-tune/` to `.gitignore`.

### Sandbox Considerations

If Codex is running in a sandbox without browser access:
- Generate the file and provide its path
- Tell the user to open it locally
- When the user returns with copied values, apply them to the source
