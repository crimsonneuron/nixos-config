{pkgs,inputs,...}:

{
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];
  services.vicinae = {
    enable = true;
    autostart = false;
  };
}
