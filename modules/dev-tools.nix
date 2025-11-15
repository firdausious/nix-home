{ pkgs, pkgs-unstable, lib, system, homeDirectory }:

let
  # Base Python packages for backend development
  basePythonPackages = ps: with ps; [
    # Core Python development tools
    pip
    virtualenv
    setuptools
    wheel
    
    # Code quality and formatting
    black
    isort
    flake8
    pylint
    mypy
    autopep8
    
    # Testing
    pytest
    pytest-cov
    pytest-asyncio
    
    # Common development libraries
    requests
    pydantic
    python-dotenv
    rich
    typer
    click
    
    # Data handling
    numpy
    pandas
    
    # Web development
    fastapi
    uvicorn
    aiohttp
    
    # Database
    psycopg2
    sqlalchemy
    
    # Utilities
    pyyaml
    gitpython
    
    # Legacy/specific packages
    scapy
  ];

  # JetBrains IDEs - using unstable for latest versions
  jetbrainsIDEs = with pkgs-unstable.jetbrains; [
    # Database IDE
    datagrip
    
    # Other JetBrains IDEs (commented out - uncomment as needed)
    # idea-ultimate      # IntelliJ IDEA Ultimate
    # idea-community     # IntelliJ IDEA Community
    # pycharm-professional  # PyCharm Professional  
    # pycharm-community     # PyCharm Community
    # webstorm              # WebStorm
    # phpstorm              # PhpStorm
    # rubymine              # RubyMine
    # clion                 # CLion
    # rider                 # Rider (.NET)
    # goland                # GoLand
    # rust-rover            # RustRover
  ];

  # Android development tools - commented out due to architecture issues
  # androidTools = with pkgs; [
  #   # Android Studio
  #   android-studio
  # ];

  # Language runtimes and tools
  languagePackages = with pkgs; [
    # Python - Common backend development environment
    (python313.withPackages basePythonPackages)

    # Ruby
    bundix
    (hiPrio bundler)
    ruby
    fastlane

    # Java
    zulu
    gradle
    maven

    # Go
    go
    air
    gopls
    go-task
    gotools
    golangci-lint
    go-migrate
    sqlc
    dbmate

    # Rust
    rustup

    # Node.js ecosystem
    nodejs_24
    bun

    # PHP
    php
    php.packages.composer

    # Other programming tools
    opencode
    protobuf
    postgresql
  ];

  # Development tools and utilities
  devUtilities = with pkgs; [
    # Version control and project management
    gh                    # GitHub CLI
    gitlab-runner        # GitLab CI runner
    
    # Database tools
    mysql80              # MySQL client
    sqlite              # SQLite
    redis               # Redis client
    
    # Container and virtualization
    docker              # Docker CLI
    docker-compose      # Docker Compose
    
    # API development and testing
    postman            # API testing (if available)
    insomnia           # API client
    
    # Text editors and utilities
    vim                # Vim editor
    
    # System monitoring and debugging
    htop              # Process monitor
    btop              # Better top
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS specific tools
    # Add macOS-specific development tools here
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux specific tools
    strace            # System call tracer
  ];

in {
  # All development packages
  devPackages = jetbrainsIDEs ++ languagePackages ++ devUtilities;
  
  # Export base Python packages for extension by other modules
  inherit basePythonPackages;
  
  # Go configuration
  go = {
    enable = true;
    package = pkgs.go;
    goPath = "${homeDirectory}/go";
    goBin = "${homeDirectory}/go/bin";
  };

  # Environment variables for development tools
  devSessionVariables = {
    # JetBrains IDEs settings
    JETBRAINS_SETTINGS = "${homeDirectory}/.config/JetBrains";
  };

  # Development-related aliases
  devAliases = {
    # Android development shortcuts
    "adb" = "${homeDirectory}/Library/Android/sdk/platform-tools/adb";
    "avdmanager" = "${homeDirectory}/Library/Android/sdk/cmdline-tools/latest/bin/avdmanager";
    "sdkmanager" = "${homeDirectory}/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager";
    "emulator" = "${homeDirectory}/Library/Android/sdk/emulator/emulator";
    
    # JetBrains IDEs shortcuts
    "fleet" = "fleet";
    "datagrip" = "datagrip";
    # "idea" = "idea-ultimate";
    # "pycharm" = "pycharm-professional";
    # "webstorm" = "webstorm";
    
    # Development utilities
    "docker-clean" = "docker system prune -af && docker volume prune -f";
    "docker-stop-all" = "docker stop $(docker ps -q)";
    "docker-rm-all" = "docker rm $(docker ps -aq)";
    
    # Database connections (examples)
    "db-local" = "psql postgresql://localhost:5432/mydb";
    # "db-dev" = "psql postgresql://dev-server:5432/mydb";
    
    # Git shortcuts
    "gst" = "git status";
    "gco" = "git checkout";
    "gp" = "git push";
    "gl" = "git pull";
    "ga" = "git add";
    "gc" = "git commit";
    "gd" = "git diff";
    "gb" = "git branch";
    "glog" = "git log --oneline --graph --decorate --all";
    
    # Project shortcuts
    "projects" = "cd ${homeDirectory}/projects";
    "dev" = "cd ${homeDirectory}/development";
  };

  # Additional PATH entries for development tools
  devSessionPath = [
    # Go binaries
    "${homeDirectory}/go/bin"
    
    # Android SDK tools
    "${homeDirectory}/Library/Android/sdk/platform-tools"
    "${homeDirectory}/Library/Android/sdk/cmdline-tools/latest/bin" 
    "${homeDirectory}/Library/Android/sdk/emulator"
    "${homeDirectory}/Library/Android/sdk/build-tools/34.0.0" # Update version as needed
    
    # Local development binaries
    "${homeDirectory}/.local/bin"
    "${homeDirectory}/development/scripts"
    
    # Flutter (if you install it manually)
    # "${homeDirectory}/development/flutter/bin"
  ];

  # Activation scripts for development tools setup
  devActivationScripts = {
    # Create Android SDK directories
    android-setup = ''
      # Create Android development directories
      mkdir -p ${homeDirectory}/Library/Android/sdk
      mkdir -p ${homeDirectory}/.android/avd
      mkdir -p ${homeDirectory}/development
      mkdir -p ${homeDirectory}/projects
      
      # Create Android SDK symlinks if Android Studio is installed
      if [ -d "/Applications/Android Studio.app" ]; then
        echo "Android Studio detected, SDK should be managed by Android Studio"
      fi
    '';
    
    # Setup development directories
    dev-dirs = ''
      # Create common development directories
      mkdir -p ${homeDirectory}/development/{scripts,tools,workspace}
      mkdir -p ${homeDirectory}/projects/{personal,work,opensource}
      
      # Create config directories for JetBrains IDEs
      mkdir -p ${homeDirectory}/.config/JetBrains
    '';
  };
}
