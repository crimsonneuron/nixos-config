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
      Exec=python ~/nixos/scripts/python/qalc.py
      Terminal=false
  '';
    #poweroff.sh 
    "${desktop_path}/poweroff.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Poweroff 
      Exec=/usr/bin/env bash -lc 'cd /home/crimson && /home/crimson/nixos/scripts/bash/poweroff.sh'
      Terminal=false
    '';
    "${desktop_path}/audioswitch.desktop".text = ''
      [Desktop Entry]
      Type=Application 
      Name=Audioswitch
      Exec=/usr/bin/env bash -lc 'cd /home/crimson && python /home/crimson/nixos/scripts/python/audioswitch.py'
      Terminal=false
    '';
    "${desktop_path}/character.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Character
      Exec=/usr/bin/env bash -lc 'cd /home/crimson && /home/crimson/nixos/scripts/bash/character_picker.sh'
      Terminal=false
    '';
  };


}
