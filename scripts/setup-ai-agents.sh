#!/usr/bin/env bash
set -euo pipefail

CAVEMAN_REPO="JuliusBrussee/caveman"

info() { printf '[INFO] %s\n' "$*"; }
ok() { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }
die() { printf '[ERROR] %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: setup-ai-agents.sh [--status] [--claude-only] [--opencode-only] [--help]

Wires token-saving tools into AI coding agents:
  - RTK for Claude Code
  - RTK for OpenCode
  - Caveman for Claude Code
  - Caveman for OpenCode

Options:
  --status        Print installed tool status only
  --claude-only   Configure Claude Code only
  --opencode-only Configure OpenCode only
  --help          Show this help
EOF
}

has() { command -v "$1" >/dev/null 2>&1; }

version_or_installed() {
  "$1" --version 2>/dev/null || printf 'installed\n'
}

claude_has_caveman() {
  has claude && claude plugin list 2>/dev/null | grep -qi caveman
}

status() {
  echo "AI agent toolchain"

  if has claude; then
    printf 'claude: %s\n' "$(version_or_installed claude)"
    if claude_has_caveman; then
      echo "claude caveman: installed"
    else
      echo "claude caveman: not installed"
    fi
  else
    echo "claude: missing"
  fi

  if has opencode; then
    printf 'opencode: %s\n' "$(version_or_installed opencode)"
  else
    echo "opencode: missing"
  fi

  if has rtk; then
    printf 'rtk: %s\n' "$(version_or_installed rtk)"
  else
    echo "rtk: missing"
  fi

  if has skills; then
    printf 'skills: %s\n' "$(version_or_installed skills)"
  else
    echo "skills: missing"
  fi
}

require() {
  has "$1" || die "missing required command: $1"
}

setup_claude() {
  require rtk
  require claude

  info "setting up RTK for Claude Code"
  rtk init -g --auto-patch

  info "installing Caveman for Claude Code"
  if claude_has_caveman; then
    ok "Caveman Claude plugin already installed"
  else
    claude plugin marketplace add "$CAVEMAN_REPO"
    claude plugin install caveman@caveman
  fi
}

setup_opencode() {
  require rtk
  require opencode
  require skills

  info "setting up RTK for OpenCode"
  rtk init -g --opencode

  info "installing Caveman for OpenCode"
  skills add "$CAVEMAN_REPO" -a opencode
}

do_claude=1
do_opencode=1

while [ $# -gt 0 ]; do
  case "$1" in
    --status) status; exit 0 ;;
    --claude-only) do_claude=1; do_opencode=0 ;;
    --opencode-only) do_claude=0; do_opencode=1 ;;
    --help|-h) usage; exit 0 ;;
    *) warn "unknown argument: $1"; usage; exit 2 ;;
  esac
  shift
done

[ "$do_claude" -eq 1 ] && setup_claude
[ "$do_opencode" -eq 1 ] && setup_opencode

ok "agent setup complete; restart Claude Code/OpenCode sessions"
