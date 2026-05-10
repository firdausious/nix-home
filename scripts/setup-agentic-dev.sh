#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
[WARN] scripts/setup-agentic-dev.sh is deprecated.

Use these focused scripts instead:
  ai-workspace-setup.sh  # local AI workspace, config, Ollama helpers
  setup-ai-agents.sh     # Claude Code/OpenCode RTK + Caveman integration

Running ai-workspace-setup.sh for compatibility...
EOF

exec "${HOME}/.config/nixpkgs/scripts/ai-workspace-setup.sh" "$@"
