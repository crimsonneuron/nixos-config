{pkgs, inputs,...}:

{
  boot.kernelModules = ["uvcvideo"];
  #users.users.crimsonneuron.extraGroups = ["video"];
  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    v4l-utils
    zoom-us
    #teams
    #^ uncomment for mcsft teams
  ];
}
