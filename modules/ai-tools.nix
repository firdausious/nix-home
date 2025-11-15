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
    requests
    httpx
    
    # Data processing and utilities
    python-dotenv
    pyyaml
    toml
    
    # Vector databases and embeddings (commented out due to compatibility issues)
    # chromadb
    # sentence-transformers
    
    # Machine learning libraries
    scikit-learn
    numpy
    pandas
    
    # Development and analysis tools
    jupyter
    ipython
    matplotlib
    seaborn
    plotly
    
    # File system utilities
    pathspec
    gitpython
  ]);

  # Python environment with AI extensions
  pythonWithAI = pkgs.python313.withPackages aiPythonPackages;

in {
  # AI/ML packages - focused on essential tools
  aiPackages = with pkgs; [
    # Core AI tools
    ollama                    # Local LLM server
    
    # API and data tools
    jq                       # JSON processing
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
  };

  # Enhanced aliases for AI development with OpenCode integration
  aiAliases = {
    # OpenCode integration
    "opencode-ai" = "cd $AI_WORKSPACE && opencode --model ollama/${aiConfig.model or "llama3.1:8b"}";
    "oc" = "opencode";
    "oc-ai" = "opencode --model ollama/${aiConfig.model or "llama3.1:8b"}";
    
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
