#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────
#  AI Fine-Tuner — Shared Installer Utilities
#  Sourced by all platform-specific installers.
# ─────────────────────────────────────────────────────────

# Colors
R='\033[0m'; B='\033[1m'; DIM='\033[2m'
BLUE='\033[38;5;69m'; CYAN='\033[38;5;75m'; GREEN='\033[38;5;78m'
YELLOW='\033[38;5;221m'; RED='\033[38;5;203m'
GRAY='\033[38;5;242m'; WHITE='\033[38;5;255m'

# Logging
info()    { echo -e "  ${CYAN}▸${R} $1"; }
success() { echo -e "  ${GREEN}✓${R} $1"; }
warn()    { echo -e "  ${YELLOW}!${R} $1"; }
fail()    { echo -e "  ${RED}✗${R} $1"; }
dim()     { echo -e "  ${GRAY}$1${R}"; }

# Banner
banner() {
  local platform="${1:-}"
  echo ""
  echo -e "${BLUE}${B}  ┌─────────────────────────────────────────┐${R}"
  echo -e "${BLUE}${B}  │${R}${CYAN}${B}        ◆ AI FINE-TUNER ◆             ${R}${BLUE}${B}│${R}"
  echo -e "${BLUE}${B}  │${R}${GRAY}      Interactive Visual Parameter       ${R}${BLUE}${B}│${R}"
  echo -e "${BLUE}${B}  │${R}${GRAY}       Tuning for AI Code Agents        ${R}${BLUE}${B}│${R}"
  echo -e "${BLUE}${B}  │${R}${DIM}${GRAY}  ═══●═══  ═══●═══  ═══●═══  ═══●═══  ${R}${BLUE}${B}│${R}"
  if [[ -n "$platform" ]]; then
    printf "${BLUE}${B}  │${R}${WHITE}  %37s  ${R}${BLUE}${B}│${R}\n" "$platform Installer"
  fi
  echo -e "${BLUE}${B}  └─────────────────────────────────────────┘${R}"
  echo ""
}

# Pre-flight: verify source files exist
preflight() {
  local script_dir="$1"; shift
  for f in "$@"; do
    if [[ ! -f "${script_dir}/${f}" ]]; then
      fail "Missing: ${script_dir}/${f}"
      fail "Run this script from the ai-fine-tuner directory."
      exit 1
    fi
  done
}

# Interactive directory picker
# Sets PROJECT_DIR variable
pick_directory() {
  echo -e "  ${WHITE}${B}Select your project directory:${R}"
  echo ""
  echo -e "  ${CYAN}[1]${R} ${WHITE}Browse${R}         ${GRAY}— Open folder picker${R}"
  echo -e "  ${CYAN}[2]${R} ${WHITE}Type path${R}      ${GRAY}— Enter path manually (Tab to autocomplete)${R}"
  echo -e "  ${CYAN}[3]${R} ${WHITE}Current dir${R}    ${GRAY}— $(pwd)${R}"
  echo ""
  read -rp "  Choose [1/2/3] (default: 3): " DIR_METHOD
  DIR_METHOD="${DIR_METHOD:-3}"

  if [[ "$DIR_METHOD" == "1" ]]; then
    if command -v osascript &>/dev/null; then
      PROJECT_DIR="$(osascript -e 'tell application "System Events" to set frontProcess to name of first process whose frontmost is true' -e 'POSIX path of (choose folder with prompt "Select your project directory")' 2>/dev/null || echo "")"
      if [[ -z "$PROJECT_DIR" ]]; then
        warn "No folder selected. Using current directory."
        PROJECT_DIR="."
      fi
    else
      warn "Folder picker not available. Enter path manually."
      read -rp "  Path: " PROJECT_DIR
      if [[ -z "$PROJECT_DIR" ]]; then PROJECT_DIR="."; fi
    fi
  elif [[ "$DIR_METHOD" == "2" ]]; then
    read -rp "  Path: " PROJECT_DIR
    if [[ -z "$PROJECT_DIR" ]]; then PROJECT_DIR="."; fi
  else
    PROJECT_DIR="."
  fi

  # Normalize path
  PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
  PROJECT_DIR="${PROJECT_DIR%/}"
  PROJECT_DIR="$(echo "$PROJECT_DIR" | sed 's/[[:space:]]*$//')"

  if [[ ! -d "$PROJECT_DIR" ]]; then
    fail "Directory does not exist: $PROJECT_DIR"
    exit 1
  fi
  echo ""
  success "Project: ${B}${PROJECT_DIR}${R}"
}

# Copy 3 templates to a target directory
copy_templates() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  cp "${src}/assets/templates/single.html" "$dest/"
  cp "${src}/assets/templates/small.html" "$dest/"
  cp "${src}/assets/templates/full.html" "$dest/"
  success "Templates → ${dest}/"
}

# Handle AGENTS.md with append/replace/skip
copy_agents_md() {
  local src="$1"
  local target="$2"

  if [[ -f "$target" ]]; then
    echo ""
    warn "AGENTS.md already exists at: $target"
    echo -e "  ${CYAN}[1]${R} Append  ${CYAN}[2]${R} Replace  ${CYAN}[3]${R} Skip"
    read -rp "  Choose [1/2/3]: " CHOICE
    case "${CHOICE:-3}" in
      1) echo "" >> "$target"; echo "---" >> "$target"; cat "${src}/AGENTS.md" >> "$target"; success "Appended to AGENTS.md" ;;
      2) cp "${src}/AGENTS.md" "$target"; success "Replaced AGENTS.md" ;;
      *) dim "Skipped AGENTS.md" ;;
    esac
  else
    mkdir -p "$(dirname "$target")"
    cp "${src}/AGENTS.md" "$target"
    success "AGENTS.md"
  fi
}

# Add .fine-tune/ to .gitignore
setup_gitignore() {
  local has_entry=""
  if [[ -f ".gitignore" ]]; then
    has_entry="$(grep "^\.fine-tune/" ".gitignore" 2>/dev/null || true)"
    if [[ -z "$has_entry" ]]; then
      echo ".fine-tune/" >> ".gitignore"
      success "Added .fine-tune/ to .gitignore"
    fi
  elif [[ -d ".git" ]]; then
    echo ".fine-tune/" > ".gitignore"
    success "Created .gitignore with .fine-tune/"
  fi
}

# Print completion + farewell message
complete_msg() {
  local tip="${1:-}"
  echo ""
  echo -e "${GREEN}${B}  ┌─────────────────────────────────────────┐${R}"
  echo -e "${GREEN}${B}  │${R}                                         ${GREEN}${B}│${R}"
  echo -e "${GREEN}${B}  │${R}  ${WHITE}${B}  Installation complete!              ${R}  ${GREEN}${B}│${R}"
  echo -e "${GREEN}${B}  │${R}                                         ${GREEN}${B}│${R}"
  echo -e "${GREEN}${B}  └─────────────────────────────────────────┘${R}"
  echo ""
  if [[ -n "$tip" ]]; then
    dim "$tip"
  fi
  dim "Try it: ask your agent \"fine-tune the shadow on this card\""
  echo ""
  echo -e "  ${GRAY}─────────────────────────────────────────${R}"
  echo ""
  echo -e "  ${WHITE}${B}Created by Muhamad Jawdat Salem Alakoum${R}"
  echo ""
  dim "Support the creator:"
  echo -e "  * ${WHITE}YottoCode${R}        — ${CYAN}https://yottocode.com${R}"
  echo -e "  * ${WHITE}Ancient Prayers${R}  — ${CYAN}https://ancientprayers.bandcamp.com${R}"
  echo -e "  * ${WHITE}LinkedIn${R}         — ${CYAN}https://linkedin.com/in/muhamad-jawdat-salem-alakoum-a79742bb${R}"
  echo ""
  dim "Thank you for using AI Fine-Tuner!"
  echo ""
  read -rp "  Press Enter to close." _
}
