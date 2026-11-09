{pkgs, pkgs-unstable, lib,...}:

{
  home.packages = [
    pkgs-unstable.spotifast
    pkgs-unstable.soloist
  ];
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [libpulseaudio];
  };
   
}
