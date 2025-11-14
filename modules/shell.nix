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
      theme = "catppuccin-mocha";
      background-opacity = 0.95;
      window-padding-x = 8;
      window-padding-y = 8;
      window-decoration = false;
      window-inherit-font-size = true;
      
      # Font configuration
      font-family = "JetBrains Mono";
      font-size = 14;
      font-weight = 500;
      
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
      
      # Colors (Catppuccin Mocha theme colors)
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      color0 = "#45475a";   # black
      color1 = "#f38ba8";   # red
      color2 = "#a6e3a1";   # green
      color3 = "#f9e2af";   # yellow
      color4 = "#89b4fa";   # blue
      color5 = "#f5c2e7";   # magenta
      color6 = "#94e2d5";   # cyan
      color7 = "#bac2de";   # white
      color8 = "#585b70";   # bright black
      color9 = "#eba0ac";   # bright red
      color10 = "#a6e3a1";  # bright green
      color11 = "#f2cdcd";  # bright yellow
      color12 = "#89b4fa";  # bright blue
      color13 = "#f5c2e7";  # bright magenta
      color14 = "#94e2d5";  # bright cyan
      color15 = "#a6adc8";  # bright white
    };
  };
}
