{config, pkgs, ...}:
let 
  desktop_path= ".local/share/applications";
in
{
  
  home.file = {
    #Calculator.py
    "${desktop_path}/calculator.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Calculator
      Exec=/usr/bin/env bash -lc 'python /home/crimson/nixos/scripts/python/qalc.py'
  '';
    #poweroff.sh 
    "${desktop_path}/poweroff.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Poweroff 
      Exec=/usr/bin/env bash -lc '/home/crimson/nixos/scripts/bash/poweroff.sh'
    '';
    "${desktop_path}/audioswitch.desktop".text = ''
      [Desktop Entry]
      Type=Application 
      Name=Audioswitch
      Exec=/usr/bin/env bash -lc 'python /home/crimson/nixos/scripts/python/audioswitch.py'
    '';
  };


}
