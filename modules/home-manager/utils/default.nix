{ config, pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./zsh.nix
    ./niri.nix
    ./yazi.nix
    ./noctalia.nix
  ];
}
