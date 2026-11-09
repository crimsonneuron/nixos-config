{pkgs, pkgs-unstable, lib,...}:

{
  home.packages = [
    pkgs-unstable.spotifast
    pkgs-unstable.soloist
  ];
   
}
