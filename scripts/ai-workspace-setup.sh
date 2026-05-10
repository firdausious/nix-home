#!/usr/bin/env bash
set -euo pipefail

AI_WORKSPACE="${AI_WORKSPACE:-$HOME/dev-ai}"
AI_CONFIG_DIR="${AI_CONFIG_DIR:-$HOME/.config/dev-ai}"
AI_MODEL="${AI_MODEL:-llama3.1:8b}"
AI_PROVIDER="${AI_PROVIDER:-ollama}"
NIXPKGS_DIR="${NIXPKGS_DIR:-$HOME/.config/nixpkgs}"

info() { printf '[INFO] %s\n' "$*"; }
ok() { printf '[OK] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
Usage: ai-workspace-setup.sh [--no-ollama] [--help]

Creates the local AI workspace used by this Nix configuration:
  $AI_WORKSPACE/{projects,scripts,data,models,logs,bin}
  $AI_CONFIG_DIR/config.json
  $AI_CONFIG_DIR/.env

Options:
  --no-ollama  Skip Ollama availability/model checks
  --help       Show this help
EOF
}

check_ollama=1
while [ $# -gt 0 ]; do
  case "$1" in
    --no-ollama) check_ollama=0 ;;
    --help|-h) usage; exit 0 ;;
    *) warn "unknown argument: $1"; usage; exit 2 ;;
  esac
  shift
done

write_if_missing() {
  local path="$1"
  if [ -e "$path" ]; then
    ok "exists: $path"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  shift
  "$@" > "$path"
  ok "created: $path"
}

copy_ai_assistant() {
  local target="$AI_WORKSPACE/ai.py"
  local template="$NIXPKGS_DIR/templates/ai.py"

  if [ -f "$target" ]; then
    ok "exists: $target"
    return 0
  fi

  if [ -f "$template" ]; then
    cp "$template" "$target"
    chmod +x "$target"
    ok "copied: $target"
    return 0
  fi

  warn "template missing: $template"
  write_if_missing "$target" cat <<'EOF'
#!/usr/bin/env python3
import os

def main():
    print("AI assistant placeholder")
    print("AI_WORKSPACE=", os.environ.get("AI_WORKSPACE", "not set"))

if __name__ == "__main__":
    main()
EOF
  chmod +x "$target"
}

create_config() {
  write_if_missing "$AI_CONFIG_DIR/config.json" cat <<EOF
{
  "model": "$AI_MODEL",
  "provider": "$AI_PROVIDER",
  "ollama_url": "http://127.0.0.1:11434",
  "temperature": 0.1,
  "max_tokens": 4096,
  "workspace_dir": "$AI_WORKSPACE",
  "data_dir": "$AI_WORKSPACE/data",
  "models_dir": "$AI_WORKSPACE/models",
  "logs_dir": "$AI_WORKSPACE/logs"
}
EOF

  write_if_missing "$AI_CONFIG_DIR/.env" cat <<EOF
AI_WORKSPACE=$AI_WORKSPACE
AI_CONFIG_DIR=$AI_CONFIG_DIR
AI_MODEL=$AI_MODEL
AI_PROVIDER=$AI_PROVIDER
OLLAMA_HOST=127.0.0.1:11434
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
PYTHONPATH=$AI_WORKSPACE/scripts:\${PYTHONPATH:-}
JUPYTER_CONFIG_DIR=$AI_CONFIG_DIR/jupyter
JUPYTER_DATA_DIR=$AI_WORKSPACE/data/jupyter
JUPYTER_RUNTIME_DIR=$AI_WORKSPACE/data/jupyter/runtime
EOF
}

create_workspace_tools() {
  write_if_missing "$AI_WORKSPACE/bin/ai" cat <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd "$AI_WORKSPACE"
exec python ai.py "\$@"
EOF
  chmod +x "$AI_WORKSPACE/bin/ai"

  write_if_missing "$AI_WORKSPACE/bin/ai-workspace" cat <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd "$AI_WORKSPACE"
echo "AI workspace: \$(pwd)"
echo "Commands:"
echo "  ai.py review <file>"
echo "  ai.py generate <description>"
echo "  ai.py analyze <path>"
echo "  ai.py chat <message>"
echo "  scripts/model-manager.py [check|list|pull] [model]"
echo "  scripts/start-jupyter"
EOF
  chmod +x "$AI_WORKSPACE/bin/ai-workspace"

  write_if_missing "$AI_WORKSPACE/scripts/model-manager.py" cat <<'EOF'
#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from pathlib import Path

def config():
    path = Path(os.environ.get("AI_CONFIG_DIR", "")) / "config.json"
    if path.exists():
        return json.loads(path.read_text())
    return {}

def run(*args, check=False):
    return subprocess.run(args, text=True, capture_output=True, check=check)

def ollama_running():
    try:
        return run("curl", "-s", "http://127.0.0.1:11434/api/tags").returncode == 0
    except Exception:
        return False

def main():
    cfg = config()
    model = sys.argv[2] if len(sys.argv) > 2 else cfg.get("model", "llama3.1:8b")
    command = sys.argv[1] if len(sys.argv) > 1 else "check"

    if not ollama_running():
        print("Ollama is not running. Start it with: llm-start")
        sys.exit(1)

    if command == "pull":
        subprocess.run(["ollama", "pull", model], check=True)
    elif command == "list":
        print(run("ollama", "list", check=True).stdout, end="")
    elif command == "check":
        print("Ollama is running")
        print(run("ollama", "list", check=True).stdout, end="")
    else:
        print("Usage: model-manager.py [check|list|pull] [model]", file=sys.stderr)
        sys.exit(2)

if __name__ == "__main__":
    main()
EOF
  chmod +x "$AI_WORKSPACE/scripts/model-manager.py"

  write_if_missing "$AI_WORKSPACE/scripts/start-jupyter" cat <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source "${AI_CONFIG_DIR:?}/.env"
mkdir -p "$JUPYTER_DATA_DIR" "$JUPYTER_RUNTIME_DIR"
cd "$AI_WORKSPACE"
exec jupyter lab \
  --notebook-dir="$AI_WORKSPACE" \
  --config-dir="$JUPYTER_CONFIG_DIR" \
  --data-dir="$JUPYTER_DATA_DIR" \
  --runtime-dir="$JUPYTER_RUNTIME_DIR" \
  --no-browser \
  --port=8888
EOF
  chmod +x "$AI_WORKSPACE/scripts/start-jupyter"
}

create_docs() {
  write_if_missing "$AI_WORKSPACE/projects/template/README.md" cat <<'EOF'
# AI Project Template

Use this as a minimal workspace project skeleton.

Commands:
- `ai.py review <file>`
- `ai.py generate "description"`
- `ai.py analyze <path>`
- `ai.py chat "message"`
EOF

  write_if_missing "$AI_WORKSPACE/README.md" cat <<EOF
# AI Workspace

Workspace managed by ~/.config/nixpkgs/scripts/ai-workspace-setup.sh.

Paths:
- Workspace: $AI_WORKSPACE
- Config: $AI_CONFIG_DIR
- Model: $AI_MODEL
- Provider: $AI_PROVIDER

Quick start:
- \`ai chat "hello world"\`
- \`llm-start\`
- \`scripts/model-manager.py check\`
- \`scripts/start-jupyter\`
EOF
}

check_default_model() {
  if [ "$check_ollama" -eq 0 ]; then
    return 0
  fi
  if ! command -v ollama >/dev/null 2>&1; then
    warn "ollama missing; apply Nix config first"
    return 0
  fi
  if ! command -v curl >/dev/null 2>&1; then
    warn "curl missing; cannot check Ollama API"
    return 0
  fi
  if ! curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    warn "ollama is not running; start it with: llm-start"
    return 0
  fi
  if ollama list | grep -q "$AI_MODEL"; then
    ok "model available: $AI_MODEL"
  else
    warn "model missing; pull it with: llm-pull $AI_MODEL"
  fi
}

info "setting up AI workspace"
info "workspace: $AI_WORKSPACE"
info "config: $AI_CONFIG_DIR"
info "model: $AI_MODEL"
info "provider: $AI_PROVIDER"

mkdir -p "$AI_WORKSPACE"/{projects,scripts,data,models,logs,bin} "$AI_CONFIG_DIR"
copy_ai_assistant
create_config
create_workspace_tools
create_docs
check_default_model

ok "AI workspace setup complete"
