{ config, pkgs, ... }:

{
  imports = [
    ./nvim.nix
    ./fuzzel.nix
    ./hyprlock.nix
    ./zsh.nix
    ./niri.nix
    ./yazi.nix
    ./noctalia.nix
    ./waybar
  ];
}
