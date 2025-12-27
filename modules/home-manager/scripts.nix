{config, pkgs, ...}:
let 
  desktop_path= ".local/share/applications";
in
{
  
  home.file = {
    "${desktop_path}/ObsidianDecrypt.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=ObsidianDecrypt
      Exec=kitty --hold sh -c "~/nixos/scripts/python/obsilogin.py"
      Icon=utilities-terminal
      Terminal=false
    '';
  };

}
