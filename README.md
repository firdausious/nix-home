# NixOS and Home-Manager Configuration

This repository contains a modular and reusable Nix configuration for managing my user environment with home-manager.

## 🏗️ Unified Configuration Architecture

This setup uses a **single folder/repo approach** that consolidates all Nix and Home Manager configurations without symlinks:

### ✅ **What's unified:**
- **All config files** in `/Users/firdaus/.config/nixpkgs/`:
  - `flake.nix` (Home Manager configuration)
  - `config.nix` (nixpkgs configuration) 
  - `nix.conf` (Nix tool configuration)
  - All your modules and custom configurations

### ✅ **How it works:**
1. **Explicit flake paths**: Home Manager commands use `--flake /path/to/your/nixpkgs` instead of relying on default locations
2. **Shell aliases**: Your `modules/shell.nix` provides convenient aliases:
   - `hm-switch` → `home-manager switch --flake ~/.config/nixpkgs#firdaus`
   - `hm-build` → `home-manager build --flake ~/.config/nixpkgs#firdaus`  
   - `hm-news` → `home-manager news --flake ~/.config/nixpkgs`
   - Plus all your existing `flakeup`, `nxb`, `nxa` aliases

### ✅ **Benefits:**
- **Single source of truth**: Everything in one versioned repository
- **No symlinks**: Clean, straightforward setup
- **No deprecation warnings**: Uses proper explicit paths
- **Manageable**: All configuration managed through your Nix modules

## Quick Start

Fresh machine setup:

1. **Install Nix**
   ```bash
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. **Pull Config**
   ```bash
   git clone https://github.com/firdausious/nixpkgs.git ~/.config/nixpkgs
   cd ~/.config/nixpkgs
   ```

3. **Enable Nix flakes**
   ```bash
   mkdir -p ~/.config/nix
   cp ~/.config/nixpkgs/nix.conf ~/.config/nix/nix.conf
   ```

4. **Dry-run the Home Manager build**
   ```bash
   nix --extra-experimental-features 'nix-command flakes' build \
     .#homeConfigurations.firdaus.activationPackage --dry-run
   ```

5. **Apply the Home Manager config**
   ```bash
   nix --extra-experimental-features 'nix-command flakes' run \
     github:nix-community/home-manager/release-25.11 -- \
     switch --flake ~/.config/nixpkgs#firdaus
   ```

6. **Restart your shell**

   After this, aliases like `hm-switch`, `ai-setup`, and `ai-agent-setup` are available.

7. **Set up AI workspace and agent integrations**
   ```bash
   ai-setup
   ai-agent-setup
   ai-agent-status
   ```

8. **Optional Neovim bootstrap**
   ```bash
   ~/.config/nixpkgs/nvim/setup.sh
   ```

   If replacing an existing Neovim setup:
   ```bash
   ~/.config/nixpkgs/nvim/setup.sh --force
   ```

### Manual Bootstrap Notes

Pull config manually if needed:
```
# Clone your forked repository
git clone https://github.com/firdausious/nixpkgs.git ~/.config/nixpkgs
cd ~/.config/nixpkgs
```

Configure Nix to use experimental features manually if aliases are not available yet:
```bash
# Copy nix.conf to proper Nix configuration directory
mkdir -p ~/.config/nix
cp ~/.config/nixpkgs/nix.conf ~/.config/nix/nix.conf

# The nix.conf enables: experimental-features = nix-command flakes
```

## 🚀 Quick Update Workflow

**When you want to add/update packages or modify your configuration:**

1. **Edit configuration files** (modify `flake.nix`, `modules/packages.nix`, etc.)
2. **Apply changes:** `hm-switch`
3. **Done!** 🎉

That's it! The `hm-switch` command builds and activates your configuration in one step.

> **Note:** Shell aliases (`hm-switch`, `hm-build`, etc.) work after you restart your shell or run `source ~/.zshrc`. If they don't work immediately, use the full command: `home-manager switch --flake ~/.config/nixpkgs#firdaus`

### **Recommended Commands**

```bash
# Primary workflow - build + activate configuration
hm-switch          # Apply configuration changes immediately
# Fallback (if aliases don't work): home-manager switch --flake ~/.config/nixpkgs#firdaus

# Optional - test before applying
hm-build           # Build without applying (for testing)
# Fallback: home-manager build --flake ~/.config/nixpkgs#firdaus

# Check for errors
flake-check        # Validate configuration syntax
# Fallback: nix flake check

# Update flake inputs (if needed)
flakeup           # Update Nix flake dependencies
# Fallback: nix flake update

# Check Home Manager news
hm-news            # See what's new in Home Manager
# Fallback: home-manager news --flake ~/.config/nixpkgs

# Example: Update flake inputs when you want newer package versions
flakeup            # Update all flake inputs (nixpkgs, nixpkgs-unstable, home-manager, etc.)
```

## 🔧 Advanced Usage

For users who need more control or troubleshooting, here are the manual methods:

### **Manual Build & Testing**

```bash
# Build configuration
nix build .#homeConfigurations.firdaus.activationPackage

# Check for errors
nix flake check

# Activate built configuration
./result/activate
```

### **Direct Run Method**

```bash
# Build and activate in one step (manual version of hm-switch)
nix run .#homeConfigurations.firdaus.activationPackage
```

### **Home Manager CLI**

```bash
# Direct home-manager command (equivalent to hm-switch)
# Use this if shell aliases don't work after initial setup
home-manager switch --flake ~/.config/nixpkgs#firdaus
```

> **Note:** Experimental features (`nix-command` and `flakes`) are already enabled in your `nix.conf`, so you don't need the `--extra-experimental-features` flags.

### **All Available Aliases**

This configuration provides convenient aliases through the shell module (`modules/shell.nix`):

#### **🎯 Primary Commands (Recommended)**

```bash
hm-switch          # Switch to new configuration (build + activate)
hm-build           # Build configuration without applying
hm-news            # Check Home Manager news
```

#### **📦 Package Management**

```bash
flakeup           # Update flake inputs
flake-show        # Show flake outputs
flake-check       # Check flake for errors
```

#### **🔧 Legacy Commands (Still Available)**

```bash
nxb               # Build configuration (equivalent to hm-build)
nxa               # Activate built configuration
```

> **Pro tip:** Use `hm-switch` for your daily workflow. The other commands are helpful for testing, debugging, or when you need more granular control over the build process.

---

# AI Development Assistant

This configuration includes a simple, language-agnostic AI assistant for code development using local LLMs via Ollama.

## AI Features

- **Language-Agnostic**: Works with Python, Javascript, Go, Rust, PHP, Java, C++, and more
- **Local LLMs**: Uses Ollama for privacy-focused local AI
- **Simple Commands**: Four simple commands: review, generate, analyze, chat
- **Git Integration**: Understands your project context
- **Minimal Setup**: Just one Python script (following LangChain requirement) and configuration
- **Cloud Optional**: Can use OpenAI/Anthropic if needed

## AI Setup

### Quick Start

1. **Apply Nix Configuration** (use `hm-switch` after completing Quick Start)

2. **Run AI Setup Script**:
   ```bash
   ai-setup
   ```

3. **Wire Claude Code and OpenCode** with RTK + Caveman:
   ```bash
   ai-agent-setup
   ai-agent-status
   ```

4. **Test the AI Assistant**:
   ```bash
   ai chat "hello world"
   ```

### Directory Structure

```
~/[workspace]/                # Configurable in modules/users/[username].nix
├── ai.py                     # Main AI assistant
├── bin/ai                    # Command wrapper
└── README.md                 # Usage guide

~/.config/[config-dir]/       # Configurable in user config
└── config.json               # Simple configuration
```

### Configuration

The AI workspace and configuration can be customized in `modules/users/[username].nix`:

```nix
aiConfig = {
  workspace = "dev-ai";              # Main AI workspace directory name
  configDir = ".config/dev-ai";      # Configuration directory  
  model = "llama3.1:8b";     # Default LLM model
  provider = "ollama";               # Default provider (ollama, openai, anthropic)
};
```

### Available Commands

```bash
# AI Assistant
ai-setup                  # Set up local AI workspace
ai-agent-setup            # Wire Claude Code/OpenCode with RTK + Caveman
ai-agent-status           # Show Claude/OpenCode/RTK/Caveman status
ai review file.py         # Review code
ai generate "web server"  # Generate code  
ai analyze .              # Analyze project
ai chat "help me debug"   # General chat

# Claude Code / OpenCode token-saving setup
rtk-claude-setup          # Install RTK hook for Claude Code
rtk-opencode-setup        # Install RTK plugin for OpenCode
caveman-claude-setup      # Install Caveman plugin for Claude Code
caveman-opencode-setup    # Install Caveman skill for OpenCode

# Ollama Management
llm-start                 # Start Ollama service
llm-stop                  # Stop Ollama service
llm-models               # List installed models
llm-chat model_name      # Chat with specific model
llm-test                 # Test connection

# Model Management
llm-pull model_name      # Download/add new models
llm-rm model_name        # Remove models
llm-show model_name      # Show model information

# Shortcuts
dev                      # Go to AI workspace
ai-workspace            # Go to AI workspace
ai-config               # Go to AI config directory
```

### Usage Examples

```bash
# Review any code file
ai review app.py
ai review main.go
ai review server.js

# Generate code in any language
ai generate "REST API with authentication" --language python
ai generate "React component for user profile" --language javascript
ai generate "HTTP server" --language go

# Analyze project structure
ai analyze ~/my-project
ai analyze .

# General development questions
ai chat "How do I optimize this SQL query?"
ai chat "Best practices for error handling in Go"
```

### Token Savings Proof

This setup uses two independent token reducers:

- **RTK** reduces noisy tool/command output before Claude Code or OpenCode sees it.
- **Caveman** reduces assistant response tokens while keeping technical substance.

Check RTK savings after real coding sessions:

```bash
rtk gain                 # Total estimated token savings
rtk gain --history       # Recent command-level savings
rtk gain --daily         # Daily savings receipt
rtk gain --graph         # ASCII savings graph
rtk discover             # Commands that could save more with RTK
rtk session              # Recent session adoption
```

Export RTK stats for reports:

```bash
rtk gain --all --format json
```

Check Caveman savings inside Claude Code:

```text
/caveman-stats
/caveman-stats --all
/caveman-stats --since 7d
/caveman-stats --share
```

Run a simple before/after comparison:

```bash
# Standard noisy output
git status
git diff
npm test

# RTK-compressed output
rtk git status
rtk git diff
rtk test npm test

# Show command-level receipt
rtk gain --history
```

For Caveman output savings, compare the same prompt in normal mode and Caveman mode, then run `/caveman-stats`:

```text
normal mode
explain this error and suggest a fix

caveman mode
explain this error and suggest a fix

/caveman-stats
```

Best daily proof after a real session:

```bash
rtk gain --daily
```

Then inside Claude Code:

```text
/caveman-stats --since 1d
```

Use both receipts together:

```text
RTK proves tool/input-output compression.
Caveman proves assistant response/output compression.
```

### Runtime Configuration

The AI assistant auto-creates a config file at `~/.config/[config-dir]/config.json`:

```json
{
  "model": "llama3.1:8b",
  "provider": "ollama", 
  "ollama_url": "http://127.0.0.1:11434",
  "temperature": 0.1
}
```

To use cloud providers, set API keys and update config:
```bash
export OPENAI_API_KEY="your-key"
export ANTHROPIC_API_KEY="your-key"
```

Then change the provider in config.json to "openai" or "anthropic".

### Supported Languages

The AI assistant automatically detects and works with:

 - **Languages**: Python, Go, Rust, PHP, Ruby, Java, C#, C, C++, Shell scripts, JavaScript, TypeScript, HTML, CSS
- **Config**: JSON, YAML, XML, SQL
- **Docs**: Markdown

Language detection is automatic based on file extensions.

### Troubleshooting

# fix linking after macos upgrade

```
# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix
```


```bash
# Check if Ollama is running
llm-test

# Start Ollama if needed
llm-start

# List available models
llm-models

# Download model if missing
ollama pull llama3.1:8b

# Check installation status
~/[workspace]/check-install.sh
```

### Privacy & Security

- **Local by default**: Uses Ollama for completely local AI
- **No data sharing**: Your code never leaves your machine
- **Optional cloud**: Can use OpenAI/Anthropic if you prefer
- **Minimal dependencies**: Just LangChain and basic Python libraries

### Customization for Other Users

To adapt this setup for another user:

1. **Copy user configuration**:
   ```bash
   cp modules/users/firdaus.nix modules/users/[new-username].nix
   ```

2. **Update the aiConfig section** in the new file:
   ```nix
   aiConfig = {
     workspace = "my-ai-workspace";     # Your preferred directory name
     configDir = ".config/my-ai";      # Your preferred config directory
     model = "your-preferred-model";   # Your preferred default model
     provider = "your-provider";       # Your preferred provider
   };
   ```

3. **Add the new user** to `modules/defaults.nix`:
   ```nix
   defaultUsers = [ "firdaus" "new-username" ];
   ```

4. **Apply the configuration**:
   ```bash
    nix run .#homeConfigurations.[new-username].activationPackage
   ```
