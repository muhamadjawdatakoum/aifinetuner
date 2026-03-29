#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────
#  AI Fine-Tuner — Cline Installer
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/install-utils.sh" ]; then
  echo "Error: Cannot find install-utils.sh. Run from the ai-fine-tuner directory."
  echo "Press Enter to close."; read -r _; exit 1
fi
. "$SCRIPT_DIR/install-utils.sh"

preflight "$SCRIPT_DIR" "AGENTS.md" \
  "assets/templates/single.html" "assets/templates/small.html" "assets/templates/full.html"

banner "Cline"

# Choose method
echo -e "  ${WHITE}${B}Installation method:${R}"
echo ""
echo -e "  ${CYAN}[1]${R} ${WHITE}AGENTS.md${R}      ${GRAY}— Project root (Cline auto-detects)${R}"
echo -e "  ${CYAN}[2]${R} ${WHITE}.clinerules/${R}   ${GRAY}— Cline native rules directory${R}"
echo -e "  ${CYAN}[3]${R} ${WHITE}Global${R}         ${GRAY}— ~/Documents/Cline/Rules/ (all projects)${R}"
echo ""
read -rp "  Choose [1/2/3] (default: 1): " METHOD
METHOD="${METHOD:-1}"

if [[ "$METHOD" != "3" ]]; then
  echo ""
  pick_directory
  cd "$PROJECT_DIR"
fi

echo ""
read -rp "  Proceed? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo ""; warn "Cancelled."; echo ""; exit 0; }
echo ""

info "Installing..."

if [[ "$METHOD" != "3" ]]; then
  copy_templates "$SCRIPT_DIR" ".fine-tune/templates"
fi

case "$METHOD" in
  2)
    mkdir -p ".clinerules"
    cp "${SCRIPT_DIR}/AGENTS.md" ".clinerules/ai-fine-tuner.md"
    success ".clinerules/ai-fine-tuner.md"
    ;;
  3)
    GLOBAL_DIR="$HOME/Documents/Cline/Rules"
    mkdir -p "$GLOBAL_DIR"
    cp "${SCRIPT_DIR}/AGENTS.md" "$GLOBAL_DIR/ai-fine-tuner.md"
    success "Global rules → $GLOBAL_DIR/ai-fine-tuner.md"
    dim "Note: templates must be installed per-project (.fine-tune/templates/)."
    ;;
  *)
    copy_agents_md "$SCRIPT_DIR" "AGENTS.md"
    ;;
esac

if [[ "$METHOD" != "3" ]]; then
  setup_gitignore
fi

complete_msg "Cline auto-detects AGENTS.md, .clinerules/, .cursorrules, and .windsurfrules."
