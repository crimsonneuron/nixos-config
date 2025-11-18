{ config, pkgs, ... }:

{
  imports = [
    ./nvim.nix
    ./fuzzel.nix
    ./hyprlock.nix
    ./quickshell.nix
    ./zsh.nix
    ./niri.nix
    ./yazi.nix
    ./waybar
  ];
}
