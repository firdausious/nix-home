{ pkgs, defaults, system, username }:

{
  # Shell aliases
  shellAliases = {
    # Nix flake management
    flakeup = "nix flake update ${defaults.nixConfigDirectory} --update-input";
    nxb = "nix build ${defaults.nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${defaults.nixConfigDirectory}/result --extra-experimental-features nix-command --extra-experimental-features flakes";
    nxa = "${defaults.nixConfigDirectory}/result/activate switch --flake ${defaults.nixConfigDirectory}/#homeConfigurations.${system}.${username}";
    
    # Home Manager with explicit flake path (unified directory approach)
    hm-switch = "home-manager switch --flake ${defaults.nixConfigDirectory}#${username}";
    hm-build = "home-manager build --flake ${defaults.nixConfigDirectory}#${username}";
    hm-news = "home-manager news --flake ${defaults.nixConfigDirectory}";
    
    # Nix flake shortcuts
    flake-show = "cd ${defaults.nixConfigDirectory} && nix flake show";
    flake-check = "cd ${defaults.nixConfigDirectory} && nix flake check";
  };

  # ZSH configuration
  zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    
    initContent = ''
      # Oh-My-Posh prompt with catppuccin theme
      if command -v oh-my-posh >/dev/null 2>&1; then
        eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/catppuccin_mocha.omp.json)"
      fi
    '';
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "dotenv"
        "jsontools"
        "web-search"
        "colored-man-pages"
        "common-aliases"
        "copypath"
        "copyfile"
      ];
    };
    
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
        };
      }
    ];
  };

  # FZF configuration
  fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude node_modules --exclude .git --exclude Pods";
    defaultOptions = [
      "--ansi"
      "--preview-window 'right:60%' --preview 'bat'"
    ];
  };

  # Ghostty terminal configuration
  ghostty = {
    enable = true;
    settings = {
      # Theme and appearance
      theme = "~/.config/ghostty/themes/catppuccin-mocha";
      background-opacity = 0.85;
      background-blur = true;
      window-padding-x = 8;
      window-padding-y = 8;
      window-decoration = false;
      window-inherit-font-size = true;
      
      # Font configuration
      font-family = "psudoFont Liga Mono";
      font-size = 13;
      font-style = "Regular";
      font-feature = "calt,liga";
      
      # Cursor and selection
      cursor-style = "block";
      cursor-color = "#f5c2e7";
      cursor-invert-fg-bg = true;
      selection-background = "#89b4fa";
      selection-foreground = "#1e1e2e";
      
      # Shell integration
      shell-integration = "zsh";
      confirm-close-surface = false;
      
      # Key bindings
      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab"
        "ctrl+shift+left=previous_tab"
        "ctrl+shift+right=next_tab"
        "ctrl+plus=increase_font_size"
        "ctrl+minus=decrease_font_size"
        "ctrl+0=reset_font_size"
      ];
      
      # Performance and behavior
      resize-delay = 0;
      gpu-acceleration = true;
      scrollback-limit = 10000;
      
      # Enhanced transparency for TUI apps like OpenCode
      adjust-cell-width = true;
      adjust-cell-height = true;
    };
  };
}
