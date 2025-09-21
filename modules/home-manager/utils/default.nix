{ config, pkgs, ... }:

{
  imports = [
    ./nvim.nix
    ./fuzzel.nix
    ./hyprlock.nix
    ./waybar
  ];
}
