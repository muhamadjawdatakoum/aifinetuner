#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────
#  AI Fine-Tuner — OpenAI Codex Installer
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/install-utils.sh" ]; then
  echo "Error: Cannot find install-utils.sh. Run from the ai-fine-tuner directory."
  echo "Press Enter to close."; read -r _; exit 1
fi
. "$SCRIPT_DIR/install-utils.sh"

preflight "$SCRIPT_DIR" "AGENTS.md" \
  "assets/templates/single.html" "assets/templates/small.html" "assets/templates/full.html"

banner "OpenAI Codex"

# Check for Codex CLI
info "Checking for Codex CLI..."
echo ""

if ! command -v codex &>/dev/null; then
  fail "Codex CLI not found."
  echo ""
  echo -e "  ${WHITE}${B}Install Codex first:${R}"
  echo -e "  ${WHITE}npm install -g @openai/codex${R}"
  echo ""
  dim "Then re-run this installer."
  echo ""
  exit 1
fi

CODEX_VERSION=$(codex --version 2>/dev/null || echo "unknown")
success "Codex found: ${B}${CODEX_VERSION}${R}"
echo ""

# Choose scope
echo -e "  ${WHITE}${B}Where would you like to install?${R}"
echo ""
echo -e "  ${CYAN}[1]${R} ${WHITE}Global${R}    ${GRAY}— Available in all projects${R}"
echo -e "               ${GRAY}Appends to ~/.codex/AGENTS.override.md${R}"
echo ""
echo -e "  ${CYAN}[2]${R} ${WHITE}Project${R}   ${GRAY}— Specific project only${R}"
echo ""

read -rp "  Choose [1/2] (default: 2): " SCOPE_CHOICE
SCOPE_CHOICE="${SCOPE_CHOICE:-2}"

if [[ "$SCOPE_CHOICE" == "1" ]]; then
  AGENTS_TARGET="$HOME/.codex/AGENTS.override.md"
  TEMPLATES_DIR="$HOME/.codex/ai-fine-tuner/templates"
  SCOPE_LABEL="global"
else
  echo ""
  pick_directory
  AGENTS_TARGET="${PROJECT_DIR}/AGENTS.md"
  TEMPLATES_DIR="${PROJECT_DIR}/.fine-tune/templates"
  SCOPE_LABEL="project"
fi

echo ""

# Summary
echo -e "  ${WHITE}${B}Installation summary:${R}"
echo ""
info "Scope:      ${B}${SCOPE_LABEL}${R}"
info "AGENTS.md:  ${B}${AGENTS_TARGET}${R}"
info "Templates:  ${B}${TEMPLATES_DIR}${R}"
echo ""

read -rp "  Proceed? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo ""; warn "Cancelled."; echo ""; exit 0; }

echo ""
info "Installing..."

# Copy templates
copy_templates "$SCRIPT_DIR" "$TEMPLATES_DIR"

# Handle AGENTS.md
if [[ "$SCOPE_LABEL" == "global" ]]; then
  mkdir -p "$(dirname "$AGENTS_TARGET")"
fi
copy_agents_md "$SCRIPT_DIR" "$AGENTS_TARGET"


# .gitignore for project scope
if [[ "$SCOPE_LABEL" == "project" ]]; then
  cd "$PROJECT_DIR"
  setup_gitignore
fi

complete_msg "Codex reads AGENTS.md automatically from your project root."
