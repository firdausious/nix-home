{ pkgs, defaults, system, username }:

{
  # Shell aliases
  shellAliases = {
    # ls aliases from common-aliases
    l = "ls -lFh";
    la = "ls -lAFh";
    lr = "ls -tRFh";
    lt = "ls -ltFh";
    ll = "ls -l";
    ldot = "ls -ld .*";
    lS = "ls -1FSsh";
    lart = "ls -1Fcart";
    lrt = "ls -1Fcrt";
    lsr = "ls -lARFh";
    lsn = "ls -1";

    # Editor and grep
    grep = "grep --color";
    sgrep = "grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} ";

    # System tools
    t = "tail -f";
    dud = "du -d 1 -h";
    ff = "find . -type f -name";
    h = "history";
    hgrep = "fc -El 0 | grep";
    help = "man";
    p = "ps -f";
    sortnr = "sort -n -r";
    unexport = "unset";

    # Safe file operations
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    # Git aliases from oh-my-zsh
    g = "git";
    ga = "git add";
    gaa = "git add --all";
    gapa = "git add --patch";
    gau = "git add --update";
    gav = "git add --verbose";
    gap = "git apply";
    gb = "git branch";
    gba = "git branch -a";
    gbd = "git branch -d";
    gbD = "git branch -D";
    gbl = "git blame -b -w";
    gbnm = "git branch --no-merged";
    gbr = "git branch --remote";
    gc = "git commit -v";
    gcamend = "git commit -v --amend";
    gcamendne = "git commit -v --no-edit --amend";
    gca = "git commit -v -a";
    gcaamend = "git commit -v -a --amend";
    gcam = "git commit -a -m";
    gcb = "git checkout -b";
    gcf = "git config --list";
    gcl = "git clone --recurse-submodules";
    gclean = "git clean -id";
    gpristine = "git reset --hard && git clean -dffx";
    gcm = "git checkout main";
    gco = "git checkout";
    gcount = "git shortlog -sn";
    gcp = "git cherry-pick";
    gcs = "git commit -S";
    gd = "git diff";
    gdca = "git diff --cached";
    gds = "git diff --staged";
    gdt = "git diff-tree --no-commit-id --name-only -r";
    gdw = "git diff --word-diff";
    gf = "git fetch";
    gfa = "git fetch --all --prune";
    gfo = "git fetch origin";
    ggl = "git pull origin";
    ggp = "git push origin";
    ggpnp = "ggl && ggp";
    ggpull = ''git pull origin "$(git_current_branch)"'';
    ggpush = ''git push origin "$(git_current_branch)"'';
    ggsup = ''git branch --set-upstream-to=origin/"$(git_current_branch)"'';
    ghh = "git help";
    gignore = "git update-index --assume-unchanged";
    gignored = ''git ls-files -v | grep "^[[:lower:]]"'';
    gk = "gitk --all --branches";
    gke = "gitk --all $(git log -g --pretty=%h)";
    gl = "git pull";
    glg = "git log --stat";
    glgp = "git log --stat -p";
    glgg = "git log --graph";
    glgga = "git log --graph --decorate --all";
    glgm = "git log --graph --max-count=10";
    glo = "git log --oneline --decorate";
    glol =
      "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'";
    glola =
      "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all";
    glog = "git log --oneline --decorate --graph";
    gloga = "git log --oneline --decorate --graph --all";
    gm = "git merge";
    gma = "git merge --abort";
    gmtl = "git mergetool --no-prompt";
    gp = "git push";
    gpd = "git push --dry-run";
    gpf = "git push --force-with-lease";
    gpfforce = "git push --force";
    gpoat = "git push origin --all && git push origin --tags";
    gpr = "git pull --rebase";
    gpu = "git push upstream";
    gpv = "git push -v";
    gr = "git remote";
    gra = "git remote add";
    grb = "git rebase";
    grba = "git rebase --abort";
    grbc = "git rebase --continue";
    grbd = "git rebase develop";
    grbi = "git rebase -i";
    grbm = "git rebase main";
    grbs = "git rebase --skip";
    grev = "git revert";
    grh = "git reset";
    grhh = "git reset --hard";
    grm = "git rm";
    grmc = "git rm --cached";
    grmv = "git remote rename";
    grrm = "git remote remove";
    grs = "git restore";
    grset = "git remote set-url";
    grss = "git restore --source";
    grst = "git restore --staged";
    grt = ''cd "$(git rev-parse --show-toplevel || echo .)"'';
    gru = "git reset --";
    grup = "git remote update";
    grv = "git remote -v";
    gsb = "git status -sb";
    gsd = "git svn dcommit";
    gsh = "git show";
    gsi = "git submodule init";
    gsp = "git show --pretty=short --show-signature";
    gsr = "git svn rebase";
    gss = "git status -s";
    gst = "git status";
    gsta = "git stash push";
    gstaa = "git stash apply";
    gstd = "git stash drop";
    gstl = "git stash list";
    gstp = "git stash pop";
    gsts = "git stash show --text";
    gsu = "git submodule update";
    gsw = "git switch";
    gswc = "git switch -c";
    gswm = "git switch main";
    gts = "git tag -s";
    gtv = "git tag | sort -V";
    gunignore = "git update-index --no-assume-unchanged";
    gunwip = ''
      git rev-list --max-count=1 --format="%s" HEAD | grep -q "\\--wip--" && git reset HEAD~1'';
    gwch = "git whatchanged -p --abbrev-commit --pretty=medium";
    gwip = ''
      git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'';
    gam = "git am";
    gamc = "git am --continue";
    gams = "git am --skip";
    gama = "git am --abort";

    # Nix flake management
    flakeup = "nix flake update ${defaults.nixConfigDirectory} --update-input";
    ncache =
      "nix flake update nixpkgs-unstable --extra-experimental-features nix-command --extra-experimental-features flakes";
    nclean = "nix-collect-garbage --delete-older-than 7d";
    nxb =
      "nix build ${defaults.nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${defaults.nixConfigDirectory}/result --extra-experimental-features nix-command --extra-experimental-features flakes";
    nxa =
      "${defaults.nixConfigDirectory}/result/activate switch --flake ${defaults.nixConfigDirectory}/#homeConfigurations.${system}.${username}";

    # Home Manager with explicit flake path (unified directory approach)
    hm-switch =
      "home-manager switch --flake ${defaults.nixConfigDirectory}#${username} --extra-experimental-features nix-command --extra-experimental-features flakes";
    hm-build =
      "home-manager build --flake ${defaults.nixConfigDirectory}#${username} --extra-experimental-features nix-command --extra-experimental-features flakes";
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
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix

      # Git helper functions
      git_current_branch() {
        git symbolic-ref --short HEAD 2>/dev/null
      }

      # Oh-My-Posh prompt with catppuccin theme
      if command -v oh-my-posh >/dev/null 2>&1; then
        eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/catppuccin_mocha.omp.json)"
      fi
    '';

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
    defaultCommand =
      "fd --type f --hidden --follow --exclude node_modules --exclude .git --exclude Pods";
    defaultOptions =
      [ "--ansi" "--preview-window 'right:60%' --preview 'bat'" ];
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
