# AI Fine-Tuner — Generic Agent Implementation

> Read `../AGENTS.md` for the full universal specification.

For agents not covered by a dedicated file: Windsurf, Cline, Continue, Aider, GitHub Copilot Workspace, bolt.new, Lovable, Replit Agent, and others.

## When to Trigger

The agent should proactively suggest the fine-tuner in these situations:

1. **Iteration detection**: You've adjusted visual values on the same element 2+ times — suggest the tuner instead of guessing.
2. **During a build**: You just wrote a new component with visual styling — offer the tuner so the user can perfect the look.
3. **Vague visual requests**: The user says "make it look better" or "the spacing feels off" — suggest the tuner immediately.
4. **Agent self-expression**: When YOU want to communicate visual options or design choices — use the tuner as your visual voice instead of listing values in text.

## Integration Methods

### Method 1: Project-Level AGENTS.md

Place `AGENTS.md` in your project root. Most modern agents read it automatically.

| Agent | Instruction File |
|---|---|
| Windsurf | `.windsurfrules` or Cascade rules |
| Cline | `.clinerules` or custom instructions |
| Continue | `.continue/config.json` → system message |
| Aider | `.aider.conf.yml` → conventions or `/read AGENTS.md` |
| Copilot Workspace | Repo-level instructions |
| bolt.new | Project-level system prompt |
| Lovable | System prompt / project instructions |
| Replit Agent | `.replit` instructions |

### Method 2: Per-Session Instruction

For agents with per-session configuration:

```
When I ask to fine-tune, tweak, or adjust visual parameters:
1. Confirm first: what will be tuned, which files read, extra token warning
2. Read my source file and extract the real element with all styles resolved
3. Pick template by control count: 1→single.html, 2-4→small.html, 5+→full.html
4. Fill in template placeholders only — do not rewrite CSS or layout
5. Include "Copy to Clipboard" button with framework-appropriate code
```

### Method 3: Minimum Viable (limited instruction space)

```
FINE-TUNE PLUGIN:
0. Confirm with user (what, files, tokens). Wait for OK.
1. Read source file. Extract ALL styles (resolve vars/tokens/classes).
2. Pick template: 1 control→single, 2-4→small, 5+→full.
3. Fill placeholders. Do NOT rewrite template CSS.
4. All controls use oninput. Preview must be the REAL element.
5. "Copy to Clipboard" button with framework code.
```

## Agent Capabilities Matrix

| Capability | Required | Fallback |
|---|---|---|
| Read project files | YES | Ask user to paste code + styles |
| Generate/write files | YES | Output HTML in chat for manual save |
| Open browser | Nice to have | Tell user to open file manually |
| Terminal access | Nice to have | Provide file path |
| Multi-file read | Helpful | For resolving imports and CSS variables |

## When the Agent Can't Read Files

1. Ask the user to paste the element's code + styles
2. Ask for: font, colors, dimensions, background context
3. Generate from pasted info
4. Caveat: "Preview may not be 100% faithful — paste your exact styles for best results"
