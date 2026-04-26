{
  description = "Modular and reusable Nix configuration";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, home-manager, nixpkgs, nixpkgs-unstable, utils, ... }@inputs:
    let
      releaseVersion = "25.11";

      # Support multiple systems
      forAllSystems = utils.lib.genAttrs utils.lib.defaultSystems;

      # Import the existing config.nix
      nixpkgsConfig = import ./config.nix;

      # Get system-specific packages
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config = nixpkgsConfig;
          overlays = [
            (import ./modules/overlays.nix {
              pkgs-unstable = unstablePkgsFor system;
            })
          ];
        };

      unstablePkgsFor = system:
        import nixpkgs-unstable {
          inherit system;
          config = nixpkgsConfig;
        };

    in {
      homeConfigurations = let
        system = "aarch64-darwin"; # Darwin system
        pkgs = pkgsFor system;
        pkgs-unstable = unstablePkgsFor system;
        lib = nixpkgs.lib;
        defaults =
          import ./modules/defaults.nix { releaseVersion = releaseVersion; };
      in lib.genAttrs defaults.defaultUsers (username:
        let
          homeDirectory = if pkgs.stdenv.isDarwin then
            "/Users/${username}"
          else
            "/home/${username}";
          userConfig =
            (import ./modules/users/${username}.nix) { inherit pkgs lib; };
          packagesConfig = import ./modules/packages.nix {
            inherit pkgs pkgs-unstable lib system;
          };
          devToolsConfig = import ./modules/dev-tools.nix {
            inherit pkgs pkgs-unstable lib system homeDirectory;
          };
          aiToolsConfig = import ./modules/ai-tools.nix {
            inherit pkgs pkgs-unstable lib homeDirectory;
            aiConfig = userConfig.aiConfig;
            basePythonPackages = devToolsConfig.basePythonPackages;
          };
        in home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [{
            home = {
              inherit username homeDirectory;
              stateVersion = defaults.stateVersion;

              packages = packagesConfig.packages ++ devToolsConfig.devPackages
                ++ aiToolsConfig.aiPackages
                ++ [ aiToolsConfig.pythonWithAIExtensions ]
                ++ userConfig.extraPackages;
              shellAliases = (import ./modules/shell.nix {
                inherit pkgs defaults system username;
              }).shellAliases // devToolsConfig.devAliases
                // aiToolsConfig.aiAliases // userConfig.extraAliases;
              sessionVariables = devToolsConfig.devSessionVariables
                // aiToolsConfig.aiSessionVariables
                // userConfig.extraSessionVariables;
              sessionPath = devToolsConfig.devSessionPath
                ++ aiToolsConfig.aiSessionPath;
            };

            programs = {
              go = devToolsConfig.go;
              zsh = (import ./modules/shell.nix {
                inherit pkgs defaults system username;
              }).zsh;
              fzf = (import ./modules/shell.nix {
                inherit pkgs defaults system username;
              }).fzf;
              # ghostty = (import ./modules/shell.nix { inherit pkgs defaults system username; }).ghostty;
              home-manager.enable = true;
            };

            # Copy theme and font files
            home.file = {
              # Ghostty theme
              ".config/ghostty/themes/catppuccin-mocha.conf".source =
                ./themes/catppuccin/ghostty/catppuccin-mocha.conf;

              # OpenCode transparent theme
              ".config/opencode/themes/transparent.json".source =
                ./themes/opencode/transparent.json;
              ".config/opencode/catppuccin-mocha.conf".source =
                ./themes/opencode/catppuccin-mocha.conf;
              ".config/opencode/tui.json".text = ''
                {
                  "$schema": "https://opencode.ai/tui.json",
                  "theme": "transparent"
                }
              '';

              # Oh-My-Posh theme
              ".config/oh-my-posh/catppuccin_mocha.omp.json".source =
                ./themes/oh-my-posh/catppuccin_mocha.omp.json;

              # Custom fonts
              ".local/share/fonts/psudoFont_Liga_Mono-Regular.ttf".source =
                ./themes/psudoFont_Liga_Mono/psudoFont_Liga_Mono_-_Regular.ttf;
              ".local/share/fonts/psudoFont_Liga_Mono-Bold.ttf".source =
                ./themes/psudoFont_Liga_Mono/psudoFont_Liga_Mono_-_Bold.ttf;
              ".local/share/fonts/psudoFont_Liga_Mono-Italic.ttf".source =
                ./themes/psudoFont_Liga_Mono/psudoFont_Liga_Mono_-_Italic.ttf;
              ".local/share/fonts/psudoFont_Liga_Mono-BoldItalic.ttf".source =
                ./themes/psudoFont_Liga_Mono/psudoFont_Liga_Mono_-_BoldItalic.ttf;
            };

            # Force overwrite for Go configuration files
            xdg.configFile."go/env".force = true;
            home.file."Library/Application Support/go/env".force = true;

            # Activation scripts
            home.activation.rustup =
              home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                # Check if rustup is available and set default stable if no default is set
                if command -v rustup >/dev/null 2>&1; then
                  if ! rustup show active-toolchain >/dev/null 2>&1; then
                    echo "Setting up Rust stable toolchain..."
                    $DRY_RUN_CMD rustup default stable
                  fi
                fi
              '';

            # Development tools activation scripts
            home.activation.android-setup =
              home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
              devToolsConfig.devActivationScripts.android-setup;
            home.activation.dev-dirs =
              home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ]
              devToolsConfig.devActivationScripts.dev-dirs;

            nixpkgs.config = nixpkgsConfig;
          }];
        });
    };
}
