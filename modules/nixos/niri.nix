{pkgs, inputs, ...}: 

{
  imports = [inputs.niri-flake.nixosModules.niri];
  nixpkgs.overlays = [inputs.niri-flake.overlays.niri];
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  services.dbus.packages = [pkgs.nautilus];
}
