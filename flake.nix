{
  description = "Modular and reusable Nix configuration";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, home-manager, nixpkgs, nixpkgs-unstable, utils, ... }@inputs:
    let
      releaseVersion = "25.05";
      
      # Support multiple systems
      forAllSystems = utils.lib.genAttrs utils.lib.defaultSystems;
      
      # Import the existing config.nix
      nixpkgsConfig = import ./config.nix;
      
      # Get system-specific packages
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = nixpkgsConfig;
        overlays = [ (import ./modules/overlays.nix { pkgs-unstable = unstablePkgsFor system; }) ];
      };
      
      unstablePkgsFor = system: import nixpkgs-unstable {
        inherit system;
        config = nixpkgsConfig;
      };
      
    in {
      homeConfigurations = 
        let
          system = "aarch64-darwin"; # Darwin system
          pkgs = pkgsFor system;
          pkgs-unstable = unstablePkgsFor system;
          lib = nixpkgs.lib;
          defaults = import ./modules/defaults.nix { releaseVersion = releaseVersion; };
        in
        lib.genAttrs defaults.defaultUsers (username: 
          let
            homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            userConfig = (import ./modules/users/${username}.nix) { inherit pkgs lib; };
            packagesConfig = import ./modules/packages.nix { inherit pkgs pkgs-unstable lib system; };
            devToolsConfig = import ./modules/dev-tools.nix { inherit pkgs pkgs-unstable lib system homeDirectory; };
            aiToolsConfig = import ./modules/ai-tools.nix { 
              inherit pkgs pkgs-unstable lib homeDirectory; 
              aiConfig = userConfig.aiConfig;
              basePythonPackages = devToolsConfig.basePythonPackages;
            };
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                home = {
                  inherit username homeDirectory;
                  stateVersion = defaults.stateVersion;

                  packages = packagesConfig.packages ++ 
                             devToolsConfig.devPackages ++ 
                             aiToolsConfig.aiPackages ++ 
                             [ aiToolsConfig.pythonWithAIExtensions ] ++
                             userConfig.extraPackages;
                  shellAliases = (import ./modules/shell.nix { inherit pkgs defaults system username; }).shellAliases // 
                                devToolsConfig.devAliases // 
                                aiToolsConfig.aiAliases // 
                                userConfig.extraAliases;
                  sessionVariables = devToolsConfig.devSessionVariables // 
                                    aiToolsConfig.aiSessionVariables // 
                                    userConfig.extraSessionVariables;
                  sessionPath = devToolsConfig.devSessionPath ++ 
                               aiToolsConfig.aiSessionPath;
                };

                programs = {
                  go = devToolsConfig.go;
                  zsh = (import ./modules/shell.nix { inherit pkgs defaults system username; }).zsh;
                  fzf = (import ./modules/shell.nix { inherit pkgs defaults system username; }).fzf;
                  ghostty = (import ./modules/shell.nix { inherit pkgs defaults system username; }).ghostty;
                  home-manager.enable = true;
                };

                # Activation scripts
                home.activation.rustup = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
                  # Check if rustup is available and set default stable if no default is set
                  if command -v rustup >/dev/null 2>&1; then
                    if ! rustup show active-toolchain >/dev/null 2>&1; then
                      echo "Setting up Rust stable toolchain..."
                      $DRY_RUN_CMD rustup default stable
                    fi
                  fi
                '';
                
                # Development tools activation scripts
                home.activation.android-setup = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] devToolsConfig.devActivationScripts.android-setup;
                home.activation.dev-dirs = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] devToolsConfig.devActivationScripts.dev-dirs;

                nixpkgs.config = nixpkgsConfig;
              }
            ];
          }
        );
    };
}
