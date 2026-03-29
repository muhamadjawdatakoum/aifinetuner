#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────
#  AI Fine-Tuner — Aider Installer
# ─────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/install-utils.sh" ]; then
  echo "Error: Cannot find install-utils.sh. Run from the ai-fine-tuner directory."
  echo "Press Enter to close."; read -r _; exit 1
fi
. "$SCRIPT_DIR/install-utils.sh"

preflight "$SCRIPT_DIR" "AGENTS.md" \
  "assets/templates/single.html" "assets/templates/small.html" "assets/templates/full.html"

banner "Aider"

pick_directory
cd "$PROJECT_DIR"

echo ""
echo -e "  ${WHITE}${B}This will install:${R}"
dim "  AGENTS.md + templates → .fine-tune/"
dim "  Configure .aider.conf.yml"
echo ""
read -rp "  Proceed? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
[[ ! "$CONFIRM" =~ ^[Yy]$ ]] && { echo ""; warn "Cancelled."; echo ""; exit 0; }
echo ""

info "Installing..."

copy_templates "$SCRIPT_DIR" ".fine-tune/templates"
copy_agents_md "$SCRIPT_DIR" "AGENTS.md"

# Configure .aider.conf.yml
AIDER_CONF=".aider.conf.yml"
if [[ -f "$AIDER_CONF" ]]; then
  if grep -q "read:.*AGENTS.md" "$AIDER_CONF" 2>/dev/null; then
    dim "AGENTS.md already in $AIDER_CONF"
  else
    echo "read: AGENTS.md" >> "$AIDER_CONF"
    success "Added 'read: AGENTS.md' to $AIDER_CONF"
  fi
else
  echo "read: AGENTS.md" > "$AIDER_CONF"
  success "Created $AIDER_CONF with 'read: AGENTS.md'"
fi

setup_gitignore

complete_msg "Aider will auto-read AGENTS.md on startup. Or: aider --read AGENTS.md"
