{ pkgs, pkgs-unstable, lib, system }:

let
  # Core system tools
  corePackages = with pkgs; [
    bash
    bat
    bottom
    cmake
    dasel
    fzf
    gawk
    gdu
    gnupg
    jq
    luarocks
    neofetch
    ripgrep
    tree-sitter
    tre-command
    watchman
    wget
    xclip
    yazi
  ];

  # Development tools (editors, etc.)
  devPackages = with pkgs; [
    nixfmt-classic
    lazygit
    neovim
    tmux
    asdf-vm
  ];

  # Infrastructure and cloud tools
  infraPackages = with pkgs; [
    dive
    trivy
    railway
    azure-cli
    awscli2
    (google-cloud-sdk.withExtraComponents [
      google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
  ];

  # Media tools
  mediaPackages = with pkgs; [
    imagemagick
    librsvg
    scrcpy
  ];

  # Platform-specific packages
  darwinPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.cocoapods
  ];

  linuxPackages = lib.optionals pkgs.stdenv.isLinux [
    # Add Linux-specific packages here
  ];

in {
  packages = corePackages ++ devPackages ++ infraPackages ++ 
             mediaPackages ++ darwinPackages ++ linuxPackages;
}
