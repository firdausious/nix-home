#!/usr/bin/env bash
set -euo pipefail

NVIM_REPO="${NVIM_REPO:-https://github.com/chaozwn/astronvim_with_coc_or_mason}"
NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"

usage() {
  cat <<'EOF'
Usage: nvim/setup.sh [--force] [--help]

Safely installs the configured Neovim distribution into ~/.config/nvim.
Existing Neovim config/state/cache directories are moved to timestamped
backups only when --force is passed.

Neovim dependencies are intentionally managed by Nix, not this script.
EOF
}

force=0
while [ $# -gt 0 ]; do
  case "$1" in
    --force) force=1 ;;
    --help|-h) usage; exit 0 ;;
    *) printf '[ERROR] unknown argument: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
  shift
done

backup_path() {
  local path="$1"
  if [ ! -e "$path" ]; then
    return 0
  fi
  local backup="${path}.bak.$(date +%Y%m%d%H%M%S)"
  mv "$path" "$backup"
  printf '[OK] backed up %s -> %s\n' "$path" "$backup"
}

if [ -e "$NVIM_CONFIG_DIR" ] && [ "$force" -ne 1 ]; then
  printf '[INFO] %s already exists. Use --force to back it up and reinstall.\n' "$NVIM_CONFIG_DIR"
  exit 0
fi

if [ "$force" -eq 1 ]; then
  backup_path "$HOME/.config/nvim"
  backup_path "$HOME/.local/share/nvim"
  backup_path "$HOME/.local/state/nvim"
  backup_path "$HOME/.cache/nvim"
fi

mkdir -p "$(dirname "$NVIM_CONFIG_DIR")"
git clone "$NVIM_REPO" "$NVIM_CONFIG_DIR"

cat <<'EOF'
[OK] Neovim config installed.

Dependency note:
  Keep CLI dependencies in Nix modules instead of installing them here with
  brew, npm, or pip. This script only manages the Neovim config checkout.
EOF
