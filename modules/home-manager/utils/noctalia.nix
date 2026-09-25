{ pkgs, ... }:
{
  home.packages = with pkgs; [
    noctalia
    gpu-screen-recorder
  ];

  xdg.configFile."noctalia/config.toml".source = ../../../dotfiles/noctalia/config.toml;
}
