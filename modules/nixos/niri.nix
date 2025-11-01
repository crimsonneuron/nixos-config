{pkgs, inputs, ...}: 

{
  imports = [inputs.niri-flake.nixosModules.niri];
  nixpkgs.overlays = [inputs.niri-flake.overlays.niri];
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  services.dbus.packages = [pkgs.nautilus];
}
