#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────
#  AI Fine-Tuner — Windsurf Installer
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/install-utils.sh" ]; then
  echo "Error: Cannot find install-utils.sh. Run from the ai-fine-tuner directory."
  echo "Press Enter to close."; read -r _; exit 1
fi
. "$SCRIPT_DIR/install-utils.sh"

preflight "$SCRIPT_DIR" "AGENTS.md" \
  "assets/templates/single.html" "assets/templates/small.html" "assets/templates/full.html"

banner "Windsurf"

pick_directory
cd "$PROJECT_DIR"

# Choose method
echo ""
echo -e "  ${WHITE}${B}Installation method:${R}"
echo ""
echo -e "  ${CYAN}[1]${R} ${WHITE}AGENTS.md${R}        ${GRAY}— Project root (recommended)${R}"
echo -e "  ${CYAN}[2]${R} ${WHITE}Windsurf rules${R}   ${GRAY}— Add to .windsurf/rules/${R}"
echo ""
read -rp "  Choose [1/2] (default: 1): " METHOD
METHOD="${METHOD:-1}"
echo ""

read -rp "  Proceed? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo ""; warn "Cancelled."; echo ""; exit 0; }
echo ""

info "Installing..."

copy_templates "$SCRIPT_DIR" ".fine-tune/templates"

if [[ "$METHOD" == "2" ]]; then
  mkdir -p ".windsurf/rules"
  cp "${SCRIPT_DIR}/AGENTS.md" ".windsurf/rules/ai-fine-tuner.md"
  success ".windsurf/rules/ai-fine-tuner.md"
else
  copy_agents_md "$SCRIPT_DIR" "AGENTS.md"
fi

setup_gitignore

complete_msg "Windsurf reads AGENTS.md automatically from your project root."
