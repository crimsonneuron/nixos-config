{ pkgs, ... }:

{
  home.packages = with pkgs; [
    brightnessctl
  ];

  # Adjust this path to wherever you put config.kdl relative to this file.
  # niri-flake runs `niri validate` on it at build time, so typos fail the
  # rebuild instead of silently falling back to the default config.
  programs.niri.config = builtins.readFile ../../../dotfiles/niri/config.kdl;
}
