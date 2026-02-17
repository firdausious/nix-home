{ pkgs-unstable }:

# Overlay to get latest versions from unstable channel
(final: prev: {
  # Development tools
  neovim = pkgs-unstable.neovim;
  dbmate = pkgs-unstable.dbmate;
  
  # Go
  go = pkgs-unstable.go;

  # Rust
  rustup = pkgs-unstable.rustup;

  # Java
  maven = pkgs-unstable.maven;
  gradle = pkgs-unstable.gradle;
  zulu25 = pkgs-unstable.zulu25;

  # Node.js ecosystem
  nodejs_24 = pkgs-unstable.nodejs_24;
  bun = pkgs-unstable.bun;
  
  # Infrastructure tools  
  opencode = pkgs-unstable.opencode;
  # ghostty = pkgs-unstable.ghostty;
  # moon = pkgs-unstable.moon;
  minio-client = pkgs-unstable.minio-client;
  railway = pkgs-unstable.railway;
  azure-cli = pkgs-unstable.azure-cli;
  awscli2 = pkgs-unstable.awscli2;
})
