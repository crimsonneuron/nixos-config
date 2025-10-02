{pkgs,pkgs-unstable, config, lib,...}:

{
  home.packages = [
    pkgs-unstable.quickshell
  ];
}
