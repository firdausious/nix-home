{ pkgs-unstable }:

# Overlay to get latest versions from unstable channel
(final: prev: {
  # Development tools
  gemini-cli = pkgs-unstable.gemini-cli;
  neovim = pkgs-unstable.neovim;
  dbmate = pkgs-unstable.dbmate;
  zed-editor = pkgs-unstable.zed-editor;
  
  # Go
  go = pkgs-unstable.go;

  # Rust
  rustup = pkgs-unstable.rustup;

  # Java
  maven = pkgs-unstable.maven;
  gradle = pkgs-unstable.gradle;

  # Node.js ecosystem
  nodejs_24 = pkgs-unstable.nodejs_24;
  bun = pkgs-unstable.bun;
  
  # Infrastructure tools  
  opencode = pkgs-unstable.opencode;
  moon = pkgs-unstable.moon;
  railway = pkgs-unstable.railway;
  azure-cli = pkgs-unstable.azure-cli;
  awscli2 = pkgs-unstable.awscli2;
})
