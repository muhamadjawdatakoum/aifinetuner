# AI Fine-Tuner — Cursor Implementation

> Read `../AGENTS.md` for the full universal specification.

## When to Trigger

Proactively suggest the fine-tuner when: (1) you've adjusted visual values 2+ times, (2) you just built a new component with visual styling, (3) the user gives vague visual feedback, or (4) you want to communicate visual options — use the tuner as your visual voice instead of listing values in text.

## Cursor-Specific Setup

### As a Cursor Rule

Add to `.cursor/rules`:

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

### As a .cursorrules File

Place `AGENTS.md` in your project root or reference it from `.cursorrules`.

### Workflow in Cursor Composer (Agent mode)

1. User: "fine-tune the shadow on the ProfileCard component"
2. Agent presents confirmation (what, files, template tier, tokens)
3. User confirms
4. Agent reads `src/components/ProfileCard.tsx`
5. Agent selects template based on control count
6. Agent fills in template placeholders
7. Agent writes `fine-tune-profile-card-shadow.html`
8. User opens in browser, tunes, clicks "Copy to Clipboard"
9. Agent applies values to source file

### Template Selection

| Controls | Template |
|----------|----------|
| 1 | `assets/templates/single.html` |
| 2–4 | `assets/templates/small.html` |
| 5+ | `assets/templates/full.html` |

### Output Location

Save to `.fine-tune/[element]-[property]/fine-tune-[element]-[property].html` alongside a `context.md` file for cross-session reuse. Add `.fine-tune/` to `.gitignore`.
