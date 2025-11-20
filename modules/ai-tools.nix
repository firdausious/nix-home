{ pkgs, pkgs-unstable, lib, homeDirectory, aiConfig, basePythonPackages }:

let
  # AI-specific Python packages extending the base backend packages
  aiPythonPackages = ps: (basePythonPackages ps) ++ (with ps; [
    # Core AI/ML packages
    langchain
    langchain-core
    langchain-community
    langchain-openai
    langchain-anthropic
    
    # HTTP and API support
    httpx
    
    # Data processing and utilities
    toml
    
    # Vector databases and embeddings (commented out due to compatibility issues)
    # chromadb
    # sentence-transformers
    
    # Machine learning libraries
    scikit-learn
    
    # Development and analysis tools
    jupyter
    ipython
    matplotlib
    seaborn
    plotly
    
    # File system utilities
    pathspec
  ]);

  # Python environment with AI extensions (extends base dev environment)
  pythonWithAI = pkgs.python313.withPackages (ps: (basePythonPackages ps) ++ (aiPythonPackages ps));

in {
  # AI/ML packages - focused on essential tools
  aiPackages = with pkgs; [
    # Core AI tools
    ollama                    # Local LLM server
    
    # API and data tools
    yq                       # YAML processing
  ];

  # Python environment with AI extensions
  pythonWithAIExtensions = pythonWithAI;

  # Environment variables for AI development
  aiSessionVariables = {
    # Ollama configuration
    OLLAMA_HOST = "127.0.0.1:11434";
    
    # Development paths (using centralized config)
    AI_WORKSPACE = "${homeDirectory}/${aiConfig.workspace}";
    AI_CONFIG_DIR = "${homeDirectory}/${aiConfig.configDir}";
    
    # OpenCode integration
    OPENCODE_MODEL_PROVIDER = "ollama";
    OPENCODE_MODEL_NAME = aiConfig.model or "llama3.1:8b";
    
    # Terminal appearance for OpenCode (catppuccin theme support)
    OPENCODE_THEME = "catppuccin-mocha";
    OPENCODE_BACKGROUND_TRANSPARENCY = "0.8";
    OPENCODE_BLUR = "true";
    
    # Source OpenCode theme configuration
    OPENCODE_CONFIG_DIR = "${homeDirectory}/.config/opencode";
  };

  # Enhanced aliases for AI development with OpenCode integration
  aiAliases = {
    # OpenCode integration with catppuccin theme
    "opencode-ai" = "cd $AI_WORKSPACE && source ~/.config/opencode/catppuccin-mocha.conf && opencode --model ollama/${aiConfig.model or "llama3.1:8b"}";
    "oc" = "source ~/.config/opencode/catppuccin-mocha.conf && opencode";
    "oc-ai" = "source ~/.config/opencode/catppuccin-mocha.conf && opencode --model ollama/${aiConfig.model or "llama3.1:8b"}";
    "oc-theme" = "source ~/.config/opencode/catppuccin-mocha.conf && opencode --theme catppuccin-mocha";
    "oc-transparent" = "source ~/.config/opencode/catppuccin-mocha.conf && OPENCODE_BACKGROUND_TRANSPARENCY=0.8 OPENCODE_BLUR=true opencode";
    
    # Core AI tools
    "ai" = "cd $AI_WORKSPACE && python ai.py";
    "ai-setup" = "bash ${homeDirectory}/.config/nixpkgs/scripts/ai-workspace-setup.sh";
    
    # Ollama management
    "llm-start" = "ollama serve";
    "llm-stop" = "pkill -f 'ollama serve'";
    "llm-models" = "ollama list";
    "llm-chat" = "ollama run";
    "llm-status" = "curl -s http://127.0.0.1:11434/api/tags | jq .";
    
    # Model management
    "llm-pull" = "ollama pull";
    "llm-rm" = "ollama rm";
    "llm-show" = "ollama show";
    
    # Code analysis with AI assistant
    "analyze" = "cd $AI_WORKSPACE && python ai.py analyze";
    "review" = "cd $AI_WORKSPACE && python ai.py review";
    "generate" = "cd $AI_WORKSPACE && python ai.py generate";
    "chat" = "cd $AI_WORKSPACE && python ai.py chat";
    
    # Workspace shortcuts
    "ai-workspace" = "cd $AI_WORKSPACE";
    "ai-config" = "cd $AI_CONFIG_DIR";
  };

  # Session paths for AI tools
  aiSessionPath = [
    "${homeDirectory}/${aiConfig.workspace}/bin"
  ];
}
