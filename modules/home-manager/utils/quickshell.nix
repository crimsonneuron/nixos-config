{pkgs,pkgs-unstable, config, lib,...}:

{
  home.packages = [
    pkgs-unstable.quickshell
    pkgs.cbonsai
    pkgs.aha
    pkgs.figlet
    pkgs.fastfetch
  ];
}
