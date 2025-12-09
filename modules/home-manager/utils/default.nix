{ config, pkgs, ... }:

{
  imports = [
    ./nvim.nix
    ./zsh.nix
    ./niri.nix
    ./yazi.nix
    #    ./noctalia.nix
    ./vicinae.nix
  ];
}
