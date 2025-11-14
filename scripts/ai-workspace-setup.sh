#!/usr/bin/env bash
# AI Workspace Setup Script
# Sets up the development environment for AI/ML work

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get configuration from environment variables
AI_WORKSPACE="${AI_WORKSPACE:-$HOME/dev-ai}"
AI_CONFIG_DIR="${AI_CONFIG_DIR:-$HOME/.config/dev-ai}"
AI_MODEL="${AI_MODEL:-llama3.1:8b}"
AI_PROVIDER="${AI_PROVIDER:-ollama}"

echo -e "${BLUE}🤖 Setting up AI Workspace${NC}"
echo "Workspace: $AI_WORKSPACE"
echo "Config Dir: $AI_CONFIG_DIR"
echo "Model: $AI_MODEL"
echo "Provider: $AI_PROVIDER"
echo

# Create workspace directories
echo -e "${GREEN}📁 Creating workspace directories...${NC}"
mkdir -p "$AI_WORKSPACE"/{projects,scripts,data,models,logs,bin}
mkdir -p "$AI_CONFIG_DIR"

# Copy AI assistant script
echo -e "${GREEN}📋 Setting up AI assistant...${NC}"
if [[ ! -f "$AI_WORKSPACE/ai.py" ]]; then
    # Try to find the template
    AI_TEMPLATE=""
    if [[ -f "$HOME/.config/nixpkgs/templates/ai.py" ]]; then
        AI_TEMPLATE="$HOME/.config/nixpkgs/templates/ai.py"
    elif [[ -f "./templates/ai.py" ]]; then
        AI_TEMPLATE="./templates/ai.py"
    else
        echo -e "${YELLOW}⚠️  AI template not found, creating basic one...${NC}"
        cat > "$AI_WORKSPACE/ai.py" << 'EOF'
#!/usr/bin/env python3
"""
Basic AI Assistant - Placeholder
Run: nix flake update && home-manager switch to get full version
"""
import os
import sys

def main():
    print("AI Assistant placeholder - please run nix setup to get full version")
    print("Current AI workspace:", os.environ.get("AI_WORKSPACE", "not set"))

if __name__ == "__main__":
    main()
EOF
    fi
    
    if [[ -n "$AI_TEMPLATE" ]]; then
        cp "$AI_TEMPLATE" "$AI_WORKSPACE/ai.py"
        chmod +x "$AI_WORKSPACE/ai.py"
        echo "✅ AI assistant copied to workspace"
    fi
else
    echo "✅ AI assistant already exists"
fi

# Create configuration file
echo -e "${GREEN}⚙️  Setting up configuration...${NC}"
CONFIG_FILE="$AI_CONFIG_DIR/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" << EOF
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
    echo "✅ Configuration created"
else
    echo "✅ Configuration already exists"
fi

# Create environment file for Python
echo -e "${GREEN}🐍 Setting up Python environment...${NC}"
ENV_FILE="$AI_CONFIG_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    cat > "$ENV_FILE" << EOF
# AI Development Environment
AI_WORKSPACE=$AI_WORKSPACE
AI_CONFIG_DIR=$AI_CONFIG_DIR
AI_MODEL=$AI_MODEL
AI_PROVIDER=$AI_PROVIDER
OLLAMA_HOST=127.0.0.1:11434

# Python optimization
PYTHONUNBUFFERED=1
PYTHONDONTWRITEBYTECODE=1
PYTHONPATH=$AI_WORKSPACE/scripts:\${PYTHONPATH:-}

# Jupyter configuration
JUPYTER_CONFIG_DIR=$AI_CONFIG_DIR/jupyter
JUPYTER_DATA_DIR=$AI_WORKSPACE/data/jupyter
JUPYTER_RUNTIME_DIR=$AI_WORKSPACE/data/jupyter/runtime
EOF
    echo "✅ Python environment file created"
else
    echo "✅ Python environment file already exists"
fi

# Create useful scripts
echo -e "${GREEN}📜 Creating utility scripts...${NC}"

# Model management script
cat > "$AI_WORKSPACE/scripts/model-manager.py" << 'EOF'
#!/usr/bin/env python3
"""
Model Management Utility
"""
import json
import os
import subprocess
import sys
from pathlib import Path

def load_config():
    config_file = Path(os.environ.get('AI_CONFIG_DIR', '')) / 'config.json'
    if config_file.exists():
        with open(config_file) as f:
            return json.load(f)
    return {}

def check_ollama():
    try:
        result = subprocess.run(['curl', '-s', 'http://127.0.0.1:11434/api/tags'], 
                              capture_output=True, text=True, timeout=5)
        return result.returncode == 0
    except:
        return False

def pull_model(model_name):
    print(f"Pulling model: {model_name}")
    try:
        subprocess.run(['ollama', 'pull', model_name], check=True)
        print(f"✅ Model {model_name} pulled successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to pull model {model_name}: {e}")
        return False

def list_models():
    try:
        result = subprocess.run(['ollama', 'list'], capture_output=True, text=True, check=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to list models: {e}")

def main():
    if not check_ollama():
        print("❌ Ollama is not running. Start it with: llm-start")
        sys.exit(1)
    
    config = load_config()
    default_model = config.get('model', 'llama3.1:8b')
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == 'pull':
            model = sys.argv[2] if len(sys.argv) > 2 else default_model
            pull_model(model)
        elif command == 'list':
            list_models()
        elif command == 'check':
            if check_ollama():
                print("✅ Ollama is running")
                list_models()
            else:
                print("❌ Ollama is not running")
        else:
            print("Usage: python model-manager.py [pull|list|check] [model]")
    else:
        print(f"Default model: {default_model}")
        if check_ollama():
            list_models()
        else:
            print("Start Ollama with: llm-start")

if __name__ == "__main__":
    main()
EOF

chmod +x "$AI_WORKSPACE/scripts/model-manager.py"

# Jupyter startup script
cat > "$AI_WORKSPACE/scripts/start-jupyter" << 'EOF'
#!/usr/bin/env bash
# Start Jupyter with AI workspace configuration

source "$AI_CONFIG_DIR/.env"

mkdir -p "$JUPYTER_DATA_DIR"
mkdir -p "$JUPYTER_RUNTIME_DIR"

echo "🚀 Starting Jupyter..."
echo "Workspace: $AI_WORKSPACE"
echo "Data Dir: $JUPYTER_DATA_DIR"

cd "$AI_WORKSPACE"
jupyter lab \
    --notebook-dir="$AI_WORKSPACE" \
    --config-dir="$JUPYTER_CONFIG_DIR" \
    --data-dir="$JUPYTER_DATA_DIR" \
    --runtime-dir="$JUPYTER_RUNTIME_DIR" \
    --no-browser \
    --port=8888
EOF

chmod +x "$AI_WORKSPACE/scripts/start-jupyter"

# Create project template
mkdir -p "$AI_WORKSPACE/projects/template"
cat > "$AI_WORKSPACE/projects/template/README.md" << 'EOF'
# AI Project Template

## Setup
```bash
cd $AI_WORKSPACE/projects
cp -r template my-new-project
cd my-new-project
```

## Usage
- Use `ai.py` for AI assistance
- Use `model-manager.py` for model management
- Use `start-jupyter` for Jupyter environment

## Scripts
- `ai.py review <file>` - Code review
- `ai.py generate "description"` - Code generation
- `ai.py analyze` - Project analysis
- `ai.py chat "message"` - General chat
EOF

# Make scripts executable
chmod +x "$AI_WORKSPACE/scripts"/*

# Initialize Ollama model
echo -e "${GREEN}🤖 Initializing Ollama model...${NC}"
if command -v ollama >/dev/null 2>&1; then
    # Check if Ollama is running
    if curl -s http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
        echo "✅ Ollama is running"
        
        # Check if model exists
        if ! ollama list | grep -q "$AI_MODEL"; then
            echo "📥 Pulling default model: $AI_MODEL"
            ollama pull "$AI_MODEL" || echo -e "${YELLOW}⚠️  Failed to pull model. Run: llm-pull $AI_MODEL${NC}"
        else
            echo "✅ Model $AI_MODEL is available"
        fi
    else
        echo -e "${YELLOW}⚠️  Ollama is not running. Start it with: llm-start${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Ollama not found. Make sure it's installed via Nix.${NC}"
fi

# Create workspace bin directory and add to PATH
echo -e "${GREEN}🔧 Setting up workspace tools...${NC}"
cat > "$AI_WORKSPACE/bin/ai-workspace" << 'EOF'
#!/usr/bin/env bash
# AI workspace management tool
cd "$AI_WORKSPACE"
echo "🤖 AI Workspace: $(pwd)"
echo "Available commands:"
echo "  ai.py review <file>     - Review code"
echo "  ai.py generate <desc>    - Generate code"
echo "  ai.py analyze           - Analyze project"
echo "  ai.py chat <msg>        - Chat with AI"
echo "  scripts/model-manager.py  - Manage models"
echo "  scripts/start-jupyter    - Start Jupyter"
EOF
chmod +x "$AI_WORKSPACE/bin/ai-workspace"

# Final setup
echo
echo -e "${GREEN}✅ AI Workspace setup complete!${NC}"
echo
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo "  cd $AI_WORKSPACE"
echo "  ./bin/ai-workspace          # Show available commands"
echo "  llm-start                   # Start Ollama"
echo "  ai.py chat 'Hello AI'       # Test AI assistant"
echo "  scripts/start-jupyter         # Start Jupyter Lab"
echo
echo -e "${BLUE}📚 Useful Aliases:${NC}"
echo "  ai-workspace               # cd to AI workspace"
echo "  ai-config                 # cd to AI config"
echo "  llm-start / llm-stop      # Manage Ollama"
echo "  llm-pull <model>          # Pull new model"
echo "  llm-chat                  # Chat with Ollama"
echo
echo -e "${GREEN}🎉 Happy AI Development!${NC}"