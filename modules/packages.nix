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
    oh-my-posh
  ];

  # Media tools
  mediaPackages = with pkgs; [
    imagemagick
    librsvg
  ];

  # Platform-specific packages
  darwinPackages = lib.optionals pkgs.stdenv.isDarwin [
    pkgs.cocoapods
  ];

  linuxPackages = lib.optionals pkgs.stdenv.isLinux [
    # Add Linux-specific packages here
  ];

in {
  packages = corePackages ++ mediaPackages ++ darwinPackages ++ linuxPackages;
}
