#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────
#  AI Fine-Tuner — Claude Code Installer
# ─────────────────────────────────────────────────────────

# Resolve script directory (handles paths with spaces)
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/install-utils.sh" ]; then
  echo "Error: Cannot find install-utils.sh. Run from the ai-fine-tuner directory."
  echo "Press Enter to close."
  read -r _
  exit 1
fi
. "$SCRIPT_DIR/install-utils.sh"

# Pre-flight
preflight "$SCRIPT_DIR" "skills/ai-fine-tuner/SKILL.md" "AGENTS.md" \
  "assets/templates/single.html" "assets/templates/small.html" "assets/templates/full.html"

banner "Claude Code"

# Check for Claude Code CLI
info "Checking for Claude Code CLI..."
echo ""

if ! command -v claude &>/dev/null; then
  fail "Claude Code CLI not found."
  echo ""
  echo -e "  ${WHITE}${B}Install Claude Code first:${R}"
  echo ""
  echo -e "  ${GRAY}# npm${R}"
  echo -e "  ${WHITE}npm install -g @anthropic-ai/claude-code${R}"
  echo ""
  echo -e "  ${GRAY}# or brew (macOS)${R}"
  echo -e "  ${WHITE}brew install claude-code${R}"
  echo ""
  dim "Then re-run this installer."
  echo ""
  exit 1
fi

CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
success "Claude Code found: ${B}${CLAUDE_VERSION}${R}"
echo ""

# Choose scope
echo -e "  ${WHITE}${B}Where would you like to install?${R}"
echo ""
echo -e "  ${CYAN}[1]${R} ${WHITE}Global${R}    ${GRAY}— Available in all projects${R}"
echo -e "               ${GRAY}Installs to ~/.claude/skills/${R}"
echo ""
echo -e "  ${CYAN}[2]${R} ${WHITE}Project${R}   ${GRAY}— Specific project only${R}"
echo ""

read -rp "  Choose [1/2] (default: 1): " SCOPE_CHOICE
SCOPE_CHOICE="${SCOPE_CHOICE:-1}"

if [[ "$SCOPE_CHOICE" == "2" ]]; then
  echo ""
  pick_directory
  INSTALL_DIR="${PROJECT_DIR}/.claude/skills/ai-fine-tuner"
  SCOPE_LABEL="project"
else
  INSTALL_DIR="$HOME/.claude/skills/ai-fine-tuner"
  SCOPE_LABEL="global"
fi

echo ""

# Summary
echo -e "  ${WHITE}${B}Installation summary:${R}"
echo ""
info "Skill:     ${B}ai-fine-tuner${R}"
info "Scope:     ${B}${SCOPE_LABEL}${R}"
info "Location:  ${B}${INSTALL_DIR}${R}"
echo ""
info "Files to install:"
dim "  SKILL.md                        (Claude skill instructions)"
dim "  assets/templates/single.html    (1-slider template)"
dim "  assets/templates/small.html     (2-4 sliders template)"
dim "  assets/templates/full.html      (5+ sliders template)"
dim "  AGENTS.md                       (universal agent spec)"
echo ""

read -rp "  Proceed with installation? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo ""; warn "Installation cancelled."; echo ""; exit 0; }

echo ""
info "Installing..."

# Create directories and copy files
mkdir -p "${INSTALL_DIR}/assets/templates" "${INSTALL_DIR}/references"
cp "${SCRIPT_DIR}/skills/ai-fine-tuner/SKILL.md" "${INSTALL_DIR}/SKILL.md"
success "SKILL.md"
copy_templates "$SCRIPT_DIR" "${INSTALL_DIR}/assets/templates"
cp "${SCRIPT_DIR}/AGENTS.md" "${INSTALL_DIR}/references/AGENTS.md"
success "references/AGENTS.md"

# .gitignore for project scope
if [[ "$SCOPE_LABEL" == "project" ]]; then
  cd "$PROJECT_DIR"
  setup_gitignore
fi

if [[ "$SCOPE_LABEL" == "global" ]]; then
  complete_msg "Installed to: ~/.claude/skills/ai-fine-tuner/ — available in all sessions."
else
  complete_msg "Installed to: ${INSTALL_DIR} — tip: commit .claude/skills/ to share with your team."
fi
